-- Heirline DB tests. Run after migrations 0001–0006 (and the local stubs when not on Supabase).
-- Every RLS policy and every database-enforced rule has an assertion here. CI fails on any FAIL.
\set ON_ERROR_STOP on
create schema if not exists t;
create table if not exists t.results(name text, ok boolean);
truncate t.results;

create or replace function t.check(name text, cond boolean) returns void language plpgsql as $$
begin insert into t.results values (name, coalesce(cond,false)); end $$;

-- run a count query as an authenticated user (RLS applies)
create or replace function t.as_user(uid uuid, q text) returns bigint language plpgsql as $$
declare n bigint;
begin
  perform set_config('request.jwt.claim.sub', uid::text, true);
  set local role authenticated;
  begin execute 'select count(*) from (' || q || ') x' into n;
  exception when others then reset role; return -1; end;   -- -1 = permission denied / error
  reset role;
  return n;
end $$;

-- run a statement expecting it to be refused; returns true if it raised
create or replace function t.fails(stmt text) returns boolean language plpgsql as $$
begin execute stmt; return false; exception when others then return true; end $$;

\o /dev/null
-- ---------- fixtures (synthetic, all fictional) ----------
do $$
declare
  blob jsonb := '{"v":1,"iv":"aa","ct":"bb","tag":"cc","key_ref":"k1"}';
  an1 uuid := '00000000-0000-0000-0000-0000000000a1'; an2 uuid := '00000000-0000-0000-0000-0000000000a2';
  anx uuid := '00000000-0000-0000-0000-0000000000a9';  -- analyst WITHOUT MFA
  ve1 uuid := '00000000-0000-0000-0000-0000000000b1'; ve2 uuid := '00000000-0000-0000-0000-0000000000b2';
  ad  uuid := '00000000-0000-0000-0000-0000000000c1'; dp  uuid := '00000000-0000-0000-0000-0000000000d1';
  fk uuid := gen_random_uuid(); fm uuid := gen_random_uuid();
  ek uuid := gen_random_uuid(); em uuid := gen_random_uuid();
  land uuid := gen_random_uuid(); shares uuid := gen_random_uuid(); mland uuid := gen_random_uuid();
  pk uuid := gen_random_uuid(); doc1 uuid := gen_random_uuid(); doc2 uuid := gen_random_uuid();
begin
  insert into auth.users(id,email) values (an1,'a1@x'),(an2,'a2@x'),(anx,'ax@x'),(ve1,'v1@x'),(ve2,'v2@x'),(ad,'ad@x'),(dp,'dp@x');
  insert into ops.staff(user_id,role,display_name,mfa_enrolled) values
    (an1,'analyst','A1',true),(an2,'analyst','A2',true),(anx,'analyst','AX',false),
    (ve1,'verifier','V1',true),(ve2,'verifier','V2',true),(ad,'admin','AD',true),(dp,'dpo','DP',true);
  insert into identity.families(id,code_name) values (fk,'KESTREL'),(fm,'MERLIN');
  insert into identity.persons(id,family_id,role,display_name) values (pk,fk,'principal',blob),(gen_random_uuid(),fm,'principal',blob);
  insert into identity.identity_variants(person_id,variant_type,value,normalised_value_hash) values (pk,'alias',blob,'\x01');
  insert into ops.engagements(id,family_id,product,assigned_analysts,verifier_id) values
    (ek,fk,'health_check',array[an1,anx],ve1),(em,fm,'health_check',array[an2],ve2);
  insert into register.assets(id,family_id,type,description) values (land,fk,'land_parcel',blob),(shares,fk,'listed_shares',blob),(mland,fm,'land_parcel',blob);
  insert into register.parcels(asset_id) values (land),(mland);
  insert into evidence.documents(id,family_id,storage_path,file_key_ref,sha256) values (doc1,fk,'p1','k','\x01'),(doc2,fk,'p2','k','\x02');
  -- A1: one land-only task (opens doc1). AX has a task too but no MFA.
  insert into ops.tasks(engagement_id,type,title,scope_asset_types,scope_document_ids,assignee) values
    (ek,'extraction_review','Review extraction',array['land_parcel']::register.asset_type[],array[doc1],an1),
    (ek,'extraction_review','AX task',array['land_parcel']::register.asset_type[],'{}',anx);
  insert into ops.consents(engagement_id,person_id,category,text_version,method) values (ek,pk,'identity','v1','esign');
  insert into audit.events(actor_id,actor_role,action,object_type,family_id) values (an1,'analyst','field.viewed','asset',fk),(ve1,'verifier','jit.opened','engagement',fk);
  perform set_config('t.fk', fk::text, false); perform set_config('t.ek', ek::text, false);
  perform set_config('t.land', land::text, false); perform set_config('t.shares', shares::text, false);
end $$;

-- ---------- RLS: task-scoped analyst ----------
select t.check('analyst sees land parcel in task scope',          t.as_user('00000000-0000-0000-0000-0000000000a1','select 1 from register.assets where type=''land_parcel'' and family_id='''||current_setting('t.fk')||'''')=1);
select t.check('analyst does NOT see shares (out of task scope)', t.as_user('00000000-0000-0000-0000-0000000000a1','select 1 from register.assets where type=''listed_shares''')=0);
select t.check('analyst does NOT see another family''s land',     t.as_user('00000000-0000-0000-0000-0000000000a1','select 1 from register.assets where family_id<>'''||current_setting('t.fk')||'''')=0);
select t.check('analyst sees only the document named in the task',t.as_user('00000000-0000-0000-0000-0000000000a1','select 1 from evidence.documents')=1);
select t.check('analyst cannot read identity without identity scope', t.as_user('00000000-0000-0000-0000-0000000000a1','select 1 from identity.persons')=0);
select t.check('analyst sees family code name via engagement',    t.as_user('00000000-0000-0000-0000-0000000000a1','select 1 from identity.families')=1);
select t.check('analyst reads nothing in another analyst''s tasks',t.as_user('00000000-0000-0000-0000-0000000000a2','select 1 from ops.tasks where assignee<>''00000000-0000-0000-0000-0000000000a2''')=0);
select t.check('analyst without MFA sees nothing',                t.as_user('00000000-0000-0000-0000-0000000000a9','select 1 from register.assets')=0);
select t.check('analyst without MFA sees no engagements',         t.as_user('00000000-0000-0000-0000-0000000000a9','select 1 from ops.engagements')=0);
update ops.tasks set scope_identity = true where assignee='00000000-0000-0000-0000-0000000000a1';
select t.check('analyst reads identity once task grants identity scope', t.as_user('00000000-0000-0000-0000-0000000000a1','select 1 from identity.persons')=1);
select t.check('identity scope still excludes other families',    t.as_user('00000000-0000-0000-0000-0000000000a1','select 1 from identity.persons where family_id<>'''||current_setting('t.fk')||'''')=0);
update ops.tasks set status='done' where assignee='00000000-0000-0000-0000-0000000000a1';
select t.check('completed task removes access',                   t.as_user('00000000-0000-0000-0000-0000000000a1','select 1 from register.assets')=0);

-- ---------- RLS: verifier needs JIT ----------
select t.check('verifier has NO standing access to the register', t.as_user('00000000-0000-0000-0000-0000000000b1','select 1 from register.assets')=0);
select t.check('verifier has NO standing access to identity',     t.as_user('00000000-0000-0000-0000-0000000000b1','select 1 from identity.persons')=0);
select t.check('verifier can see own engagement',                 t.as_user('00000000-0000-0000-0000-0000000000b1','select 1 from ops.engagements')=1);
select t.check('JIT reason must be at least 10 chars',            t.fails($$insert into ops.jit_sessions(verifier_id,engagement_id,family_id,reason,expires_at) values ('00000000-0000-0000-0000-0000000000b1',current_setting('t.ek')::uuid,current_setting('t.fk')::uuid,'short',now()+interval '4 hours')$$));
select t.check('JIT cannot exceed 4h without renewal',            t.fails($$insert into ops.jit_sessions(verifier_id,engagement_id,family_id,reason,expires_at) values ('00000000-0000-0000-0000-0000000000b1',current_setting('t.ek')::uuid,current_setting('t.fk')::uuid,'Sign-off for KESTREL',now()+interval '6 hours')$$));
insert into ops.jit_sessions(verifier_id,engagement_id,family_id,reason,expires_at)
  values ('00000000-0000-0000-0000-0000000000b1',current_setting('t.ek')::uuid,current_setting('t.fk')::uuid,'Sign-off for KESTREL',now()+interval '4 hours');
select t.check('open JIT grants the verifier the whole KESTREL register', t.as_user('00000000-0000-0000-0000-0000000000b1','select 1 from register.assets')=2);
select t.check('open JIT grants identity read',                   t.as_user('00000000-0000-0000-0000-0000000000b1','select 1 from identity.persons')=1);
select t.check('JIT never reaches another family',                t.as_user('00000000-0000-0000-0000-0000000000b1','select 1 from register.assets where family_id<>'''||current_setting('t.fk')||'''')=0);
select t.check('a different verifier gets nothing from that JIT', t.as_user('00000000-0000-0000-0000-0000000000b2','select 1 from register.assets')=0);
update ops.jit_sessions set closed_at = now();
select t.check('closed JIT removes access immediately',           t.as_user('00000000-0000-0000-0000-0000000000b1','select 1 from register.assets')=0);
insert into ops.jit_sessions(verifier_id,engagement_id,family_id,reason,opened_at,expires_at)
  values ('00000000-0000-0000-0000-0000000000b1',current_setting('t.ek')::uuid,current_setting('t.fk')::uuid,'Sign-off for KESTREL',now()-interval '5 hours',now()-interval '1 hour');
select t.check('expired JIT grants nothing',                      t.as_user('00000000-0000-0000-0000-0000000000b1','select 1 from register.assets')=0);

-- ---------- RLS: admin and DPO ----------
select t.check('admin sees NO register rows (no routine client data access)', t.as_user('00000000-0000-0000-0000-0000000000c1','select 1 from register.assets')=0);
select t.check('admin sees NO identity rows',                     t.as_user('00000000-0000-0000-0000-0000000000c1','select 1 from identity.persons')=0);
select t.check('admin sees NO documents',                         t.as_user('00000000-0000-0000-0000-0000000000c1','select 1 from evidence.documents')=0);
select t.check('admin sees all engagements (metadata)',           t.as_user('00000000-0000-0000-0000-0000000000c1','select 1 from ops.engagements')=2);
select t.check('admin reads the audit log',                       t.as_user('00000000-0000-0000-0000-0000000000c1','select 1 from audit.events')=2);
select t.check('DPO reads the audit log',                         t.as_user('00000000-0000-0000-0000-0000000000d1','select 1 from audit.events')=2);
select t.check('DPO reads the consent register',                  t.as_user('00000000-0000-0000-0000-0000000000d1','select 1 from ops.consents')=1);
select t.check('DPO sees NO register rows',                       t.as_user('00000000-0000-0000-0000-0000000000d1','select 1 from register.assets')=0);
select t.check('analyst cannot read the audit log',               t.as_user('00000000-0000-0000-0000-0000000000a1','select 1 from audit.events')=0);
select t.check('verifier cannot read the audit log',              t.as_user('00000000-0000-0000-0000-0000000000b1','select 1 from audit.events')=0);
select t.check('nobody authenticated can read wrapped keys',      t.as_user('00000000-0000-0000-0000-0000000000c1','select 1 from crypto.family_keys')=-1);
select t.check('nobody authenticated can read website leads',     t.as_user('00000000-0000-0000-0000-0000000000c1','select 1 from leads.consultation_requests')=-1);

-- ---------- writes are denied to authenticated (service role only) ----------
create or replace function t.write_as_user(uid uuid, stmt text) returns boolean language plpgsql as $$
begin
  perform set_config('request.jwt.claim.sub', uid::text, true);
  set local role authenticated;
  begin execute stmt; reset role; return false;
  exception when others then reset role; return true; end;
end $$;
select t.check('authenticated cannot insert assets',              t.write_as_user('00000000-0000-0000-0000-0000000000a1','insert into register.assets(family_id,type) values (gen_random_uuid(),''other'')'));
select t.check('authenticated cannot update tasks',               t.write_as_user('00000000-0000-0000-0000-0000000000a1','update ops.tasks set status=''done'''));
select t.check('authenticated cannot delete audit events',        t.write_as_user('00000000-0000-0000-0000-0000000000c1','delete from audit.events'));

-- ---------- database-enforced rules ----------
select t.check('engagement: verifier cannot also be a preparer (VER-1)', t.fails($$insert into ops.engagements(family_id,product,assigned_analysts,verifier_id) values (current_setting('t.fk')::uuid,'health_check',array['00000000-0000-0000-0000-0000000000a1'::uuid],'00000000-0000-0000-0000-0000000000a1')$$));
select t.check('verification: preparer <> signer constraint',     t.fails($$insert into ops.verifications(engagement_id,preparer_id,verifier_id,statement_template_version) values (current_setting('t.ek')::uuid,'00000000-0000-0000-0000-0000000000b1','00000000-0000-0000-0000-0000000000b1','v1')$$));
insert into ops.verifications(id,engagement_id,preparer_id,verifier_id,statement_template_version) values ('00000000-0000-0000-0000-00000000e001',current_setting('t.ek')::uuid,'00000000-0000-0000-0000-0000000000a1','00000000-0000-0000-0000-0000000000b1','v1');
select t.check('cannot sign an empty checklist',                  t.fails($$update ops.verifications set signed_at=now(), signature_ref='sig' where id='00000000-0000-0000-0000-00000000e001'$$));
insert into ops.verification_items(verification_id,asset_class,label) values ('00000000-0000-0000-0000-00000000e001','land','Titles reviewed');
select t.check('cannot sign with an open checklist item (VER-2)', t.fails($$update ops.verifications set signed_at=now(), signature_ref='sig' where id='00000000-0000-0000-0000-00000000e001'$$));
update ops.verification_items set done_at=now(), done_by='00000000-0000-0000-0000-0000000000b1';
select t.check('cannot sign without a signature reference',       t.fails($$update ops.verifications set signed_at=now() where id='00000000-0000-0000-0000-00000000e001'$$));
update ops.verifications set signed_at=now(), signature_ref='sig' where id='00000000-0000-0000-0000-00000000e001';
select t.check('signing succeeds when checklist complete',        (select signed_at is not null from ops.verifications where id='00000000-0000-0000-0000-00000000e001'));
select t.check('a signed verification is immutable',              t.fails($$update ops.verifications set statement_template_version='v2' where id='00000000-0000-0000-0000-00000000e001'$$));

select t.check('evidence item without examiner match or human resolution is rejected (fail closed)', t.fails($$insert into evidence.evidence_items(document_id,page,field_name,value) select id,1,'holder_name','{"v":1,"iv":"a","ct":"b","tag":"c","key_ref":"k"}' from evidence.documents limit 1$$));
select t.check('non-ciphertext cannot be stored in an enc_blob column', t.fails($$insert into identity.persons(family_id,role,display_name) values (current_setting('t.fk')::uuid,'heir','{"name":"plaintext"}')$$));
select t.check('recovery case cannot be Recovered without outcome + evidence', t.fails($$insert into ops.recovery_cases(engagement_id,type,status) values (current_setting('t.ek')::uuid,'dormant','recovered')$$));
select t.check('report link longer than 7 days is rejected',      t.fails($$insert into ops.report_links(report_id,token_hash,recipient,expires_at) select gen_random_uuid(),'\x01','{"v":1,"iv":"a","ct":"b","tag":"c","key_ref":"k"}',now()+interval '30 days'$$) );
select t.check('duplicate payment webhook is idempotent (unique provider_ref)', (
  select (insert_ok and dup_blocked) from (select true as insert_ok, t.fails($$insert into ops.payments(engagement_id,provider,provider_ref,amount,currency) values (current_setting('t.ek')::uuid,'paystack','ref1',1,'NGN'),(current_setting('t.ek')::uuid,'paystack','ref1',1,'NGN')$$) as dup_blocked) z));

-- config packs
insert into config.config_versions(pack,jurisdiction,version,content_yaml,sha256,effective_from,created_by)
  values ('title_rules','NG-LA','2026.11.0','pack: title_rules', extensions.digest(convert_to('pack: title_rules','UTF8'),'sha256'), current_date, '00000000-0000-0000-0000-0000000000c1');
select t.check('config sha256 must match content',                t.fails($$insert into config.config_versions(pack,jurisdiction,version,content_yaml,sha256,effective_from,created_by) values ('fee_schedule','NG-LA','x','abc','\x00',current_date,'00000000-0000-0000-0000-0000000000c1')$$));
select t.check('config approver must differ from author (four-eyes)', t.fails($$update config.config_versions set approved_by='00000000-0000-0000-0000-0000000000c1', approved_at=now()$$));
update config.config_versions set approved_by='00000000-0000-0000-0000-0000000000b2', approved_at=now();
select t.check('approved config is immutable',                    t.fails($$update config.config_versions set content_yaml='changed'$$));
select t.check('approved config cannot be deleted',               t.fails($$delete from config.config_versions$$));
select t.check('every staff role can read config packs',          t.as_user('00000000-0000-0000-0000-0000000000a1','select 1 from config.config_versions')=1);

-- ---------- audit chain ----------
select t.check('audit chain verifies',                            (select ok from audit.verify_chain()));
select t.check('audit.events cannot be updated',                  t.fails($$update audit.events set action='x'$$));
select t.check('audit.events cannot be deleted',                  t.fails($$delete from audit.events$$));
select t.check('audit.events cannot be truncated',                t.fails($$truncate audit.events$$));
alter table audit.events disable trigger audit_no_update;
update audit.events set reason='tampered' where seq = (select min(seq) from audit.events);
alter table audit.events enable trigger audit_no_update;
select t.check('tampering is detected by verify_chain',           (select not ok from audit.verify_chain()));

-- ---------- coverage ----------
select t.check('RLS enabled + forced on every table',             (select count(*)=0 from public.rls_coverage_gaps()));

\o
-- ---------- report ----------
select case when ok then 'PASS' else 'FAIL' end as result, name from t.results order by ok, name;
select count(*) filter (where ok) as passed, count(*) filter (where not ok) as failed from t.results;
