# Premium Scroll-Driven Web Design Techniques (2025–2026): Luxury vs Gimmick, for Heirline

Research date: 2026-11-11. Scope: technique reference for a restrained, scroll-driven marketing site for a discreet private-client wealth firm (ink navy, ivory, brass, high-contrast serif display, hairline rules, calm pacing). Sources are mostly primary docs (Chrome for Developers, web.dev, Lenis repo, NN/g) plus practitioner write-ups. Listicle-grade trend sources are marked as such. Guidance dated before 2025 is marked **[older]**.

Note on live examples: in this session I verified primary documentation and demo URLs. I did **not** verify specific live luxury or wealth-management sites that use each technique, so this file gives few "live example" URLs beyond official demos, Codrops tutorials and Apple-style references. See each Gaps section.

---

## 1. Browser support in 2026 for CSS scroll-driven animations, and fallbacks

### Takeaway
CSS scroll-driven animations (`animation-timeline: scroll()` / `view()`) became **Baseline Newly available in October 2026**, when Firefox 159 turned them on by default. Chrome/Edge have had them since 115 and Safari since 26. Native CSS is now a sound default for simple scroll-linked effects. Still feature-detect and gate on `prefers-reduced-motion`, because "Newly available" means many users are on older versions, Firefox in particular.

### Cited Findings
- "Firefox 159 enables scroll-driven animations by default." "With support in Chrome, Safari, and now Firefox 159, scroll-driven animations are Baseline Newly available." Support list: Chrome 115, Edge 115, Firefox 159, Safari 26. — [web.dev, New to the web platform in October 2026](https://web.dev/blog/web-platform-10-2026)
- Safari 26 shipped scroll-driven animations (September 2025 roundup). — [web.dev, New to the web platform in September 2025](https://web.dev/blog/web-platform-09-2025)
- Before 159, Firefox kept the feature behind `layout.css.scroll-driven-animations.enabled` in stable (one source says this was still true as of Firefox 152, June 2026). — [buildmvpfast, Replace Your Scroll-Listener JS](https://www.buildmvpfast.com/blog/css-scroll-driven-animations-replace-js-2026) (third-party; superseded by the web.dev Oct 2026 post)
- A third-party article says Safari added threaded (off-main-thread) scroll-driven animations in 26.4. **Not verified against an Apple primary source.** — [lilting.ch](https://lilting.ch/en/articles/chrome-146-scroll-animation-safari-grid-lanes)
- How it works: `animation-timeline: scroll(<scroller> <axis>)` takes scroller `nearest|root|self` and axis `block|inline|x|y`. `animation-timeline: view(<axis> <inset>)` tracks an element's visibility in its nearest scroll ancestor. Declare `animation-timeline` *after* the `animation` shorthand, because the shorthand resets it. The JS equivalents are `new ScrollTimeline({source, axis})` and `new ViewTimeline({subject, axis, inset})`. — [Chrome for Developers, Scroll-driven animations](https://developer.chrome.com/docs/css-ui/scroll-driven-animations)
- `animation-range` values: `cover` (default, full range), `entry`, `exit`, `entry-crossing`, `exit-crossing`, `contain`. Ranges can be combined, e.g. `entry 25% cover 50%`. Ranges are computed from the untransformed box, so `scale`/`translate` don't shift them. — [Chrome for Developers](https://developer.chrome.com/docs/css-ui/scroll-driven-animations)
- Performance: the docs say scroll-driven animations can run "off the main thread", unlike main-thread scroll handlers, which are "subject to jank". They advise animating `transform` rather than layout properties (e.g. `width`) to get composited animation. — [Chrome for Developers](https://developer.chrome.com/docs/css-ui/scroll-driven-animations)
- Official demos (useful reference, not luxury examples): image reveal https://scroll-driven-animations.style/demos/image-reveal/css/ ; stacking cards https://scroll-driven-animations.style/demos/stacking-cards/css/ ; reading progress https://scroll-driven-animations.style/demos/progress-bar/css/scroll-defaults.html ; range visualiser https://goo.gle/view-timeline-range-tool — [Chrome for Developers](https://developer.chrome.com/docs/css-ui/scroll-driven-animations)
- Related: "scroll-triggered animations" (time-based animations fired at a scroll position, as opposed to scrubbed) appeared in a March 2026 platform roundup (Chrome). — [lavx news summary of web.dev March 2026](https://news.lavx.hu/article/new-to-the-web-platform-in-march-2026-container-queries-scroll-triggered-animations-and-more) (aggregator; check the primary web.dev post)

### Inferences
- Recommended fallback pattern: wrap all scroll-linked CSS in `@supports (animation-timeline: view()) { @media (prefers-reduced-motion: no-preference) { … } }`. The default (unsupported/reduced) state should be the *final composed state*: text visible, images in place. Older browsers then get a calm static editorial page, which suits Heirline's brand.
- Use native CSS for simple reveals, hairline-rule draws, progress indicators and subtle parallax offsets. Use GSAP ScrollTrigger only where you need pinning with precise choreography, sequenced timelines, canvas frame sequences or video scrubbing.
- Keep animated properties to `transform`, `opacity`, `clip-path` (and `filter` sparingly) to stay on the compositor.

### Gaps
- I found no official list of which properties each engine runs on the compositor for scroll timelines.
- I did not verify Safari 26.x threaded-animation details or `timeline-scope` support status across browsers (Chrome docs mention it as experimental in Chrome 116 behind a flag; that is older info).
- I did not fetch a polyfill recommendation in this session. The commonly referenced `flackr/scroll-timeline` polyfill is unverified here.

---

## 2. Layered or dimensional parallax heroes (background, subject, foreground, atmosphere planes)

### Takeaway
Top practice in 2025–2026 is *small differential motion* between 3–4 cut-out planes, driven by scroll (transform-only), often combined with a slow scale/zoom of the whole stack rather than large opposing offsets. NN/g's testing shows parallax still carries usability costs even in its subtler modern form. For a wealth firm, the motion should be nearly subliminal, and the layers should serve one composed photograph, not a "diorama".

### Cited Findings
- Codrops (Oct 29, 2025, Joffrey Spitzer): "Building a Layered Zoom Scroll Effect with GSAP ScrollSmoother and ScrollTrigger". It uses a single timeline that scales front image layers so the planes move as one coordinated system. — [Codrops](https://tympanus.net/codrops/2025/10/29/building-a-layered-zoom-scroll-effect-with-gsap-scrollsmoother-and-scrolltrigger/)
- Codrops (2026) tutorials continue to pair GSAP + Lenis for parallax depth, e.g. "The Never Ending Story: Building a Seamless Infinite Scroll Experience with GSAP & Lenis" (May 28, 2026) and "Building an Infinite GSAP Scroll Gallery with Parallax and Flip Transitions" (Jul 30, 2026). — [Codrops May 2026](https://tympanus.net/codrops/2026/05/28/the-never-ending-story-building-a-seamless-infinite-scroll-experience-with-gsap-lenis/); [Codrops Jul 2026](https://tympanus.net/codrops/2026/07/30/building-an-infinite-gsap-scroll-gallery-with-parallax-and-flip-transitions/)
- Codrops' 2025 year-in-review indexes the year's scroll/typography tutorials (incl. 3D scroll-driven text with CSS and GSAP, and an infinite parallax grid). — [Codrops 2025 year in review](https://tympanus.net/codrops/2025/12/29/2025-a-very-special-year-in-review/)
- NN/g: parallax has returned in more restrained form but testing "reveals a familiar cast and storyline: unimpressed users and a range of usability issues". "The ultimate test of parallax usability is whether users can easily and quickly complete their task." — [NN/g, Parallax Usability](https://www.nngroup.com/articles/parallax-usability/) **[older: NN/g article predates 2025]**
- Fast Company, citing NN/g's Katie Sherwin: the newer, subtler parallax "still has all the same UX problems as the older, more obnoxious kind." — [Fast Company](https://www.fastcompany.com/90309395/why-parallax-scrolling-needs-to-die) **[older, 2019]**
- Ranges and transforms: `view()` timelines with `animation-range` (e.g. `exit`) let a hero plane move only while the hero is leaving the viewport. Ranges aren't affected by the transforms applied, so planes can be translated without feedback loops. — [Chrome for Developers](https://developer.chrome.com/docs/css-ui/scroll-driven-animations)

### Inferences
- **Expensive:** a single photographed or rendered scene split into planes, with offsets of roughly a few percent of viewport height; the slowest plane is the background and the subject is almost still. An "atmosphere" plane (soft haze, light falloff or grain) moves least or fades. Motion ends when the hero exits. Type sits on its own plane but stays legible and still once read. Pair it with a slight overall scale (1.0 → 1.04) rather than big translation.
- **Cheap:** mismatched cut-outs with visible halos, layers that drift so far that edges or gaps appear, mouse-tilt parallax on the hero, mountains/clouds stock imagery, parallax on every section, and text moving at a different rate from its own paragraph.
- **Implementation options:** (a) native CSS `animation-timeline: view()` with `animation-range: exit` and `translate`/`scale` per plane, lightest and compositor-friendly; (b) GSAP ScrollTrigger `scrub` timeline if the planes must be choreographed with pinned copy; (c) WebGL (three.js/OGL) with depth maps is only worth it for a true camera-move effect. It costs a JS/GPU budget and a loading stage, and for a discreet firm it risks reading as "tech demo".
- **Performance:** use separate `<img>`/AVIF layers sized for their plane, `will-change: transform` only on active planes, and avoid animating `filter: blur()` on large layers. Serve a separate flattened mobile composition.

### Gaps
- I verified no live luxury or private-bank sites using layered heroes in this session.
- I found no quantitative guidance (e.g. maximum offset percentages) from primary sources; the numbers above are inference.

---

## 3. Pinned scrollytelling sections (sticky stage, content changes with progress): pacing, length, avoiding scroll-jacking

### Takeaway
Distinguish *pinning with native scroll* (a `position: sticky` stage while the document scrolls normally) from *scroll-jacking* (altering scroll rate, direction or duration). NN/g's 2023 testing found scroll-jacking harms control, discoverability and task success, worst when it is long, alters rate while text must be read, changes direction, or runs on mobile. Short, purposeful, progressively disclosing pinned sections that keep native scroll physics are the acceptable form.

### Cited Findings
- NN/g "Scrolljacking 101" (Sara Paul, Aug 6, 2023): sites with scrolljacking "exhibit significant threats to user control and freedom, discoverability, attention, efficiency, and task success". On one full scrolljacked Crypto.com page, all participants were disoriented. — [NN/g](https://www.nngroup.com/articles/scrolljacking-101/) **[2023 but still the main usability study]**
- Lengthy scrolljacks were much worse; some users thought the page was broken. Short ones (BBC example) kept users oriented because normal scrolling resumed soon. — [NN/g](https://www.nngroup.com/articles/scrolljacking-101/)
- "A scrolljack is beneficial when it gradually adds supporting information to lessen cognitive load and support storytelling." — [NN/g](https://www.nngroup.com/articles/scrolljacking-101/)
- Pages that "altered the rate and duration of scrolling while also requiring the user to read text exhibited the most severe usability issues"; NN/g advises "against including important content inside of a scrolljack section." — [NN/g](https://www.nngroup.com/articles/scrolljacking-101/)
- "Avoid Changing the Scroll Direction" (horizontal scrolljacks are risky). On mobile, "in most cases, they are not" worth it. Sticky navigation acted as an "escape hatch". Place them "below the fold to highlight key calls to action already present above the fold." — [NN/g](https://www.nngroup.com/articles/scrolljacking-101/)
- Task-oriented users were far less tolerant than exploratory users. — [NN/g](https://www.nngroup.com/articles/scrolljacking-101/)
- NN/g gives no numeric maximum length and no guidance on progress indicators. — [NN/g](https://www.nngroup.com/articles/scrolljacking-101/)

### Inferences
- For Heirline (a task-oriented audience of principals, family offices and advisers looking for credibility and contact), use at most 1–2 pinned chapters (e.g. "how we steward across generations" as 3–4 steps). Keep each pin short, roughly 1.5–3 viewport heights of scroll distance (inference, not a sourced number), with native scroll speed and no snapping that fights the user.
- Keep critical copy (services, credentials, contact) outside pinned sequences or fully readable in the static state. Show a quiet hairline progress indicator (e.g. brass rule filling via `animation-timeline: scroll()` on the section's view timeline) so users know the pin is finite.
- Keep the sticky header visible as the escape hatch. On mobile, unpin and present the steps as a normal vertical stack.
- **Implementation options:** CSS `position: sticky` stage plus `view-timeline` on step markers (native, no JS); GSAP ScrollTrigger `pin: true, scrub: true` with `anticipatePin` and `invalidateOnRefresh` for complex choreography. GSAP's plugins are now fully free (see §7), so cost isn't a factor.
- **Expensive:** a stage that changes one thing at a time (an image crossfade, a single line of text, a rule drawing), generous dwell between states, and ending on a still composed frame.
- **Cheap:** multi-screen horizontal galleries hijacked from vertical scroll, "scroll to explore" prompts, pins that each last 5+ screens, and numbers counting up inside the pin.

### Gaps
- No 2025–2026 empirical study beyond NN/g 2023 was found. Pacing numbers above are practitioner inference, not sourced.

---

## 4. Scroll-scrubbed video (`video.currentTime` tied to scroll): encoding, image-sequence alternative, mobile/iOS pitfalls

### Takeaway
Smooth scrubbing depends on keyframe density, not on JS. Encode **all-intra (`-g 1`)** or a very short GOP, at the rendered size only, with no audio, `yuv420p` and faststart. Ship VP9/WebM first with H.264/MP4 as the Safari/iOS fallback. All-intra files are large, so keep clips short and small. The alternative, used by Apple product pages, is an image sequence drawn to a `<canvas>`. It gives frame-perfect control at a heavy request and memory cost.

### Cited Findings
- Root cause: normal encodes place keyframes every 2–10 s; "when GSAP sets currentTime sixty times a second — the browser can only cheaply land on a keyframe," causing stutter. The fix is all-intra, `-g 1`, so "every single frame becomes an I-frame". — [hontran.dev, scroll-scrubbed video stutters fix](https://www.hontran.dev/blog/scroll-scrubbed-video-stutters-fix)
- Exact commands from that source:
  - `ffmpeg -i in.mov -vf scale=1280:-2 -r 30 -movflags faststart -vcodec libx264 -crf 23 -g 1 -pix_fmt yuv420p -an out.mp4`
  - `ffmpeg -i in.mov -vf scale=1280:-2 -r 30 -c:v libvpx-vp9 -crf 32 -b:v 0 -g 1 -pix_fmt yuv420p -an -row-mt 1 out.webm`
  — [hontran.dev](https://www.hontran.dev/blog/scroll-scrubbed-video-stutters-fix)
- Sizes: a 1080p all-intra clip "can blow past 100 MB". At ~1280px and 30 fps the author got ~8 MB MP4 / ~13 MB WebM, versus ~1–2 MB for a normal encode (illustrative). "Never encode all-intra at a resolution larger than the element's rendered size." — [hontran.dev](https://www.hontran.dev/blog/scroll-scrubbed-video-stutters-fix)
- Safari/iOS: VP9 isn't reliable, so MP4/H.264 is required. Without `-pix_fmt yuv420p` "Safari may show a black box". List WebM first. Use `muted` and `playsinline`, never call `.play()`, and use `preload="auto"` because unbuffered frames can't be seeked. — [hontran.dev](https://www.hontran.dev/blog/scroll-scrubbed-video-stutters-fix)
- Middle ground: community gists say `-g 1` is the smoothest option but basically doubles file size, and suggest `-g 2` as a balance; other examples use `-keyint_min 6 -g 6`. — [gist (jamespantalones)](https://gist.github.com/jamespantalones/7e19ed338874458e868de8659ed3e823); [gist (janily)](https://gist.github.com/janily/19e762ac9aab6a50350ede51b065eb53) (community advice, not authoritative)
- **[older, Oct 2022]** Browser behaviour test: desktop Safari scrubbed best even with sparse keyframes; Chrome needed dense keyframes; Firefox was choppy with MP4 even with dense keyframes, so WebM is needed there. iOS Safari handled delta frames well but sparse keys were less smooth on an iPhone mini. Keyframe-every-10 commands: `ffmpeg -i input-video.mp4 -vcodec libvpx-vp9 -g 10 -acodec copy output-10.webm` and `ffmpeg -i input-video.mp4 -vcodec libx264 -x264-params keyint=10:scenecut=0 -acodec copy output-10.mp4`. A 5x denser keyframe file was ~5x larger. — [Muffin Man, Scrubbing videos using JavaScript](https://muffinman.io/blog/scrubbing-videos-using-javascript/)
- Image-sequence alternative (Apple AirPods Pro style): a fixed/sticky canvas stays in the viewport, scroll progress maps to a frame index, and that frame's image is drawn to the canvas. — [CSS-Tricks, "Let's Make One of Those Fancy Scrolling Animations Used on Apple Product Pages"](https://css-tricks.com/?p=308477) **[older, ~2020]**; GSAP ScrollTrigger version: [GSAP forum, AirPods image sequence using ScrollTrigger](https://gsap.com/community/forums/topic/25188-airpods-image-sequence-animation-using-scrolltrigger/) **[older]**
- A near-pure-CSS image-sequence approach using scroll-driven animations also exists. — [geyer.dev, CSS image sequence animations](https://hn.jakechampion.name/reader/https://geyer.dev/blog/css-image-sequence-animations) (read via mirror; not fetched in full)

### Inferences
- For Heirline, a scrubbed clip should be short (3–6 s of source, roughly 90–180 frames at 30 fps), slow-moving and tonal (e.g. light moving across a brass seal, a fountain pen line, a slow dolly through a library). Fast action looks janky when users scroll erratically.
- Encode two sizes (desktop ~1280–1600 px wide, mobile ~720–900 px portrait crop), lazy-load once the section is near, and show a poster frame until enough is buffered.
- Smooth the scrub: interpolate the target `currentTime` (lerp) rather than setting it raw on every scroll event. GSAP `scrub: 0.5–1` or Lenis-driven rAF does this.
- **Canvas sequence vs video:** use a canvas sequence (AVIF/WebP frames, ~60–120 frames) when frame accuracy matters across all browsers and the clip is short. Use all-intra video when the frame count is high (bandwidth is usually lower than hundreds of images). WebCodecs-based decoding is an advanced alternative (not researched here).
- **Expensive:** product-film quality, slow, matched to a sentence of copy, ending on a still.
- **Cheap:** a 360° object spin for its own sake, visible stutter, a long blank pin while frames load, and scroll-video on every section.

### Gaps
- No primary Apple engineering source and no MDN guidance specifically on scrub encoding were found. Guidance is practitioner-sourced.
- I didn't verify current iOS 26 behaviour (e.g. Low Power Mode effects on video decode, memory limits for large canvas sequences) from a primary source.
- AV1 suitability for all-intra scrubbing was not researched.

---

## 5. Kinetic and editorial serif typography (line reveals, masked text, variable weight on scroll, huge display type)

### Takeaway
Line-by-line masked reveals of large serif display type remain the signature of premium editorial sites. GSAP's SplitText is now free and was rewritten, which has made the effect easier but also more common. Restraint (one reveal per heading, line-level not letter-level, short durations, no re-triggering) is what separates luxury from template.

### Cited Findings
- GSAP is now "100% FREE including ALL of the bonus plugins like SplitText, MorphSVG". — [GSAP GitHub](https://github.com/greensock/GSAP)
- Webflow (GSAP's owner) made all GSAP tools free for everyone, including former Club plugins, and announced a major SplitText upgrade "with 14 new features". — [Webflow blog, GSAP becomes free](https://webflow.com/blog/gsap-becomes-free)
- Codrops' on-scroll typography series: rotation and scale values "can create a sense of depth, movement, and emphasis on the typography". — [Codrops On-Scroll Typography Animations](https://tympanus.net/codrops/2023/01/18/on-scroll-typography-animations) **[older, 2023]**; also [Some More On-Scroll Typography Animations](https://tympanus.net/codrops/2023/02/22/some-more-on-scroll-typography-animations) **[older]** and [On-Scroll Expanding Image Animation within Typography](https://tympanus.net/codrops/2024/04/02/on-scroll-expanding-image-animation-within-typography) **[older, 2024]**
- 2025: Codrops published a tutorial on 3D scroll-driven text animations with CSS and GSAP (listed in its year in review). — [Codrops 2025 year in review](https://tympanus.net/codrops/2025/12/29/2025-a-very-special-year-in-review/)

### Inferences
- **Expensive for Heirline:**
  - Large high-contrast serif headings revealed line by line with an `overflow: clip` mask and `translateY(100%) → 0`. Use a ~0.8–1.2 s ease-out (e.g. `expo.out`/`power3.out`) with a small stagger (60–120 ms), triggered once (`toggleActions: "play none none none"` or a `view()` `entry` range), never replayed on scroll back up.
  - Hairline rules that draw (`scaleX` from 0) under section headings.
  - Very large type used sparingly as composition, e.g. a single word or numeral as a chapter marker.
  - Optical sizing (`font-optical-sizing`/`opsz`) set correctly for display sizes.
- **Overdone/cheap:**
  - Per-character staggered "typewriter" or scramble effects.
  - Weight or width "breathing" tied to scroll on body copy (variable-weight-on-scroll reads as a demo unless it's one hero word).
  - Text that scrubs in and out in both directions.
  - Rotating 3D text.
  - Outlined or stroked giant type with marquee motion.
  - Gradient-filled text.
  - Blur-in on every paragraph.
- **Accessibility:** split text must keep an accessible label (SplitText adds `aria-label` options, unverified here). Avoid animating body paragraphs, and keep `prefers-reduced-motion` to a plain fade or no motion.
- **Implementation:** GSAP SplitText + ScrollTrigger (most robust line detection; re-splits on resize). Native CSS can handle masked reveals of pre-split lines via `view()`, but line breaks in fluid layouts need JS.

### Gaps
- No primary-source design critique specifically labelling kinetic serif patterns as "luxury" vs "overdone" was found. Those judgments are inference.
- SplitText 2025 rewrite feature list (e.g. `autoSplit`, `mask: "lines"`, aria handling) not verified in this session.

---

## 6. Cursor and pointer interactions (custom cursors, magnetic buttons, hover image reveals, spotlight/lens)

### Takeaway
No authoritative source declares these "dated". The debate centres on usability. Custom cursors that replace the system pointer and magnetic CTAs are now widely sold as drop-in components (Framer and Webflow marketplaces), which is a strong sign of template saturation. For a discreet firm, keep the native cursor. If anything, use a refined hover image reveal in a list (e.g. insights or principals) and subtle underline/rule animations.

### Cited Findings
- Framer marketplace sells multiple "magnetic button" components, with vendor copy calling them "the hallmark of modern, high-end web design". — [Framer marketplace, magnetic buttons](https://www.framer.com/marketplace/components/magneticbuttons) (vendor framing, not evidence of quality)
- Webflow "Made in Webflow" has cloneable "Custom Cursor, Magnetic Buttons and Menu Interactions" templates. — [Webflow](https://webflow.com/made-in-webflow/website/Custom-Cursor-Magnetic-Buttons-and-Menu-Interactions)
- Critique: an essay argues websites should stop replacing the default pointer, comparing it to "Don't roll your own crypto". — [Feedbagel, Why websites should stop replacing the default mouse pointer cursor](https://feedbagel.com/post/dont-hijack-my-mouse-pointer) (full argument not retrieved)
- Awwwards/Readymag guidance: a custom cursor "is a powerful aesthetic gesture that attracts much attention" and "deserves respect"; custom cursors don't work on mobile. — [Awwwards, Customize your mouse cursor (Aug 18, 2021)](https://awwwards.com/customize-your-mouse-cursor-inspirational-examples-implementation-tricks.html) **[older]**
- Counter-view (low authority): magnetic cursor effects are "best" when they feel "like an extension of the user's own intent instead of a gimmick". — [brainy.ink glossary](https://brainy.ink/paper/glossary/magnetic-cursor)
- Trend listicles treat custom cursors as a trend with a mobile caveat (no cursor on touch devices) and advise that core pointer functionality is never compromised. — [tinyfrog web design trends 2026](https://tinyfrog.com/web-design-trends); [Digital Thrive trends 2025–2026](https://www.digitalthriveai.com/en-ca/resources/web-design/web-design-trends/) (listicles)

### Inferences
- **Dated/gimmicky by 2026 (because they are commoditised as one-click components):**
  - A blob or circle cursor follower with lag.
  - "Drag"/"View" text inside the cursor.
  - Magnetic pull on every button.
  - `mix-blend-mode: difference` cursors.
  - Cursor trails.
  - A spotlight/flashlight that hides content until hovered (also an accessibility problem).
- **Still refined:**
  - The native cursor, with precise hover states (underline drawing from left in brass, a slight color shift to brass on links).
  - A hover image reveal on a text list, a small image fading or clipping in near the row, desktop only, with `pointer: fine` gating.
  - A very subtle lens or zoom only on an artwork or object image where inspection is the point.
- **Implementation:** gate with `@media (hover: hover) and (pointer: fine)`. Use transforms only, plus `pointer-events: none` on decorative followers. Never hide the system cursor on form fields or links.

### Gaps
- No Awwwards jury commentary or survey data specifically declaring these effects dated was found.

---

## 7. Page transitions (View Transitions API, Barba/Swup, shared-element transitions)

### Takeaway
Same-document view transitions are Baseline (Chrome 111, Safari 18, Firefox 144 since Oct 2025). Cross-document (MPA) transitions via `@view-transition { navigation: auto; }` work in Chrome/Edge and Safari. Firefox support is partial or emerging (and is an Interop 2026 focus area). That means MPA sites can get progressive-enhancement page transitions with no router library. Barba/Swup remain options only if you need identical transitions in all browsers today.

### Cited Findings
- Same-document view transitions: Chrome 111, Edge 111, Safari 18, Firefox 144 (stable Oct 14, 2025), which made them Baseline Newly available. Firefox's initial version lacks view transition types. — [Chrome for Developers, What's new in view transitions (2025 update), Oct 8, 2025](https://developer.chrome.com/blog/view-transitions-in-2025)
- `view-transition-name: match-element`: Chrome 137, Firefox 144, Safari 18.4 (same-document only). Nested view transition groups: Chrome 140 only. Scoped view transitions (`element.startViewTransition()`): experimental. `document.activeViewTransition`: Chrome 142, Firefox 147, Safari 26.2. — [Chrome for Developers](https://developer.chrome.com/blog/view-transitions-in-2025)
- Cross-document view transitions shipped in Chrome in 2024, and Safari added support. — [Chrome for Developers](https://developer.chrome.com/blog/view-transitions-in-2025)
- Cross-document transitions require both pages to opt in with `@view-transition { navigation: auto; }` and are limited to same-origin navigations. — [Chrome for Developers, Cross-document view transitions](https://developer.chrome.com/docs/web-platform/view-transitions/cross-document)
- caniuse lists Firefox as partial for cross-document view transitions from 144 (143 disabled by default). Chrome's docs list Firefox 147 for `pageswap`/`pagereveal` events. Sources disagree on exact Firefox completeness. — [caniuse, cross-document view transitions](https://caniuse.com/cross-document-view-transitions); [Chrome for Developers](https://developer.chrome.com/docs/web-platform/view-transitions/cross-document)
- Cross-document view transitions are part of Interop 2026. — (reported in search summary; primary Interop 2026 page not fetched; treat as likely but unverified)

### Inferences
- For Heirline, use a quiet cross-document transition: a ~300–450 ms crossfade of the root, plus one shared element (e.g. the wordmark or an insight's hero image morphing into the article header via `view-transition-name`). Wrap it in `@media (prefers-reduced-motion: no-preference)`. Browsers without support simply navigate normally, which is acceptable.
- **Cheap:** full-screen colored wipes or curtains on every click, loading-screen counters (0–100%), long transitions that delay content, and logo animations on each navigation.
- **Expensive:** near-imperceptible continuity (the image you clicked becomes the header), with the transition shorter than the page load would have felt.
- Barba.js/Swup (SPA-like hijacked navigation) add complexity (re-initialising scripts, analytics, focus management). With native cross-document VT available, they are no longer the default recommendation (inference). Lenis has a `stopInertiaOnNavigate` option relevant to such setups. — [Lenis README](https://github.com/darkroomengineering/lenis)

### Gaps
- Exact Safari version for cross-document view transitions not confirmed in this session (commonly cited as Safari 18.2; unverified).
- I did not research current Barba/Swup maintenance status for 2025–2026.

---

## 8. Smooth scroll libraries (Lenis): still recommended in 2026? Accessibility trade-offs

### Takeaway
Lenis (darkroom.engineering, v1.3.x) is still the de facto smooth-scroll layer in award-style builds and in Codrops tutorials through 2026. Unlike older transform-based libraries (Locomotive v4, early ScrollSmoother patterns), it keeps native scroll, so `position: sticky`, anchors and find-in-page work, and it respects `prefers-reduced-motion` by default. The trade-offs are input latency and feel (lerp inertia), Safari's 60 fps cap, iframe and nested-scroll issues, and Thoughtworks' accessibility caution. For a calm, task-oriented wealth site, it's optional. If used, keep it light and let reduced-motion users opt out (the default).

### Cited Findings
- Lenis current install snippets reference version 1.3.27. Defaults: `lerp: 0.1`, `duration: 1.2`, `smoothWheel: true`, `respectReducedMotion: true`. — [Lenis GitHub README](https://github.com/darkroomengineering/lenis)
- Lenis "wraps the browser's own scroll, so position: sticky, anchor links, and accessibility keep working." — [Lenis README](https://github.com/darkroomengineering/lenis)
- Reduced motion: when the user prefers reduced motion, smoothing is disabled and programmatic scrolls jump instantly, and Lenis keeps running so "WebGL/DOM synchronization stays intact". Opting out of this is possible but "not recommended". — [Lenis README](https://github.com/darkroomengineering/lenis)
- Limitations: no CSS scroll-snap support (use `lenis/snap`); "capped to 60fps on Safari" and 30 fps in Low Power Mode; smoothing stops over iframes; position fixed may lag on pre-M1 macOS Safari; `syncTouch` can misbehave on iOS < 16; nested scroll needs `data-lenis-prevent` or `allowNestedScroll` (the latter "can create performance issues since it checks the DOM tree on every scroll event"). By default anchors are blocked while scrolling unless `anchors: true`. — [Lenis README](https://github.com/darkroomengineering/lenis)
- Thoughtworks Technology Radar (Oct 2024): Lenis can have accessibility issues, particularly with vertical and horizontal scrolling interactions, which could confuse users with disabilities, and needs careful implementation. — [Thoughtworks Radar, Lenis](https://thoughtworks.com/radar/languages-and-frameworks/lenis) **[older, 2024]**
- Locomotive's workshop docs argue Lenis smooths native scroll rather than hijacking it, resolving earlier accessibility problems of transform-based smooth scroll. — [Locomotive workshop docs](https://one-page-to-life.workshops.locomotive.ca/docs/chapter-1/locomotive-scroll)
- GSAP forum: Lenis doesn't smooth scrollbar dragging or keyboard scrolling, and a commenter says accessibility can trump full smoothing. — [GSAP forum](https://gsap.com/community/forums/topic/36030-use-scrollsmoother-features-with-lenis-scroll/)
- Codrops' 2026 tutorials still pair GSAP + Lenis. — [Codrops May 2026](https://tympanus.net/codrops/2026/05/28/the-never-ending-story-building-a-seamless-infinite-scroll-experience-with-gsap-lenis/)
- General smooth-scroll downsides (motion sensitivity, screen-reader issues) are described by a non-primary source. — [Digital Thrive, Downsides of Smooth Scrolling](https://digitalthriveai.com/en-au/resources/ui-ux/downsides-of-smooth-scrolling/) (undated, low authority)

### Inferences
- **Recommendation for Heirline:** native scroll by default is defensible and calmer. If Lenis is used (e.g. to steady a scrubbed video or canvas sequence), set a gentle `lerp` (~0.08–0.12), keep `smoothWheel` only, and don't enable `syncTouch` (leave mobile native). Keep `respectReducedMotion: true`. Use `anchors: true` with header offset. Add `data-lenis-prevent` on any modal or scrollable panel. Drive GSAP from Lenis's rAF (`lenis.on('scroll', ScrollTrigger.update)` plus `gsap.ticker`) so there's one clock.
- **Feels expensive:** a barely perceptible ease that makes pinned and scrubbed sections steady. **Feels cheap:** heavy, floaty inertia (`lerp` < 0.05) where the page keeps moving after the user stops, which reads as lag and frustrates trackpad users.
- Native CSS scroll-driven animations work with Lenis because Lenis keeps native scroll position.

### Gaps
- No 2025–2026 formal accessibility audit (WCAG) of Lenis was found.
- I found no data on what share of 2026 Awwwards SOTD sites use Lenis.

---

## 9. Saturated 2023–2026 trends recognisable as template work

### Takeaway
The strongest evidence of saturation is commoditisation: patterns sold as drop-in Framer and Webflow components or described by trend listicles as the "default". Bento grids are now the default feature-section layout. Magnetic buttons and custom cursors are packaged marketplace components. For a discreet wealth firm, almost all of these signal "startup template" rather than "old money".

### Cited Findings
- Bento grids: one source lists them as falling out of favour in 2025 ("overused and predictable"); other 2026 guides say they've become the default pattern for feature sections, replacing card layouts. — [tinyfrog, Web Design Trends 2026: What's In and What's Out](https://tinyfrog.com/web-design-trends); [Digital Thrive trends 2025–2026](https://www.digitalthriveai.com/en-ca/resources/web-design/web-design-trends/) (listicles; opinion)
- Magnetic buttons and custom cursors are sold as plug-in components and cloneable templates. — [Framer marketplace](https://www.framer.com/marketplace/components/magneticbuttons); [Webflow Made in Webflow](https://webflow.com/made-in-webflow/website/Custom-Cursor-Magnetic-Buttons-and-Menu-Interactions)
- AirPods-style scroll image sequences are packaged as libraries and Webflow cloneables (e.g. MIT-licensed canvas-scroll-clip; "GSAP Image Sequence Scrub (Apple AirPods)" on Made in Webflow). — [cssscript canvas-scroll-clip](https://www.cssscript.com/image-sequence-animation-canvas-clip/); [Webflow cloneable](https://webflow.com/made-in-webflow/website/gsap-video-animation-on-scroll)
- Scrolljacked horizontal sections are documented as harmful. — [NN/g](https://www.nngroup.com/articles/scrolljacking-101/)

### Inferences (no primary source; based on the commoditisation pattern plus the brand brief)
- **Template-coded for Heirline (avoid):**
  - Big-number counters ("$4.2B AUM" counting up), which also risk looking boastful for a discreet firm.
  - Marquee logo or client strips (and discretion means you shouldn't show clients anyway).
  - "Scroll to explore" bouncing chevrons and mouse icons.
  - Bento grids of services.
  - Glassmorphism cards.
  - Animated noise or mesh gradients and aurora blobs.
  - Blob cursors and magnetic CTAs.
  - Pinned horizontal galleries.
  - Preloader percentage counters.
  - Per-letter text scrambles.
  - Testimonial carousels.
  - Grain overlays on everything.
  - Oversized pill buttons with arrow-rotate hovers.
  - Dark-mode neon accent glows.
- **Signals that read as luxury and restraint:**
  - Generous whitespace and a strict editorial grid.
  - Few, well-placed photographs, given large and treated consistently.
  - Hairline rules and small caps or tracked labels.
  - One signature motion moment (e.g. the hero, or one pinned chapter), with motion elsewhere limited to once-only line reveals.
  - Native cursor and native scroll feel.
  - Fast load.
  - Content that reads perfectly with motion disabled.

### Gaps
- No quantitative survey (e.g. Awwwards dataset analysis) of trend saturation was found. I found nothing on marquee strips, glassmorphism or noise gradients being "saturated" from primary design sources. Those classifications are inference.
- Live luxury or private-wealth reference sites were not verified this session. The report writer should treat any named examples as needing verification.

---

## Cross-cutting implementation summary (inference, built on the sources above)

| Technique | Best default tool (2026) | Fallback / reduced motion | Perf cost |
|---|---|---|---|
| Hero plane parallax | CSS `view()` + `animation-range: exit`, transforms | Static composed hero | Low (compositor) |
| Line reveals / rule draws | GSAP SplitText (free) or CSS `view()` `entry` on pre-split lines | Text visible, no motion | Low |
| Pinned chapter | CSS sticky + view timelines; GSAP `pin` for complex | Unpinned stacked steps | Low–medium |
| Scrubbed video | GSAP ScrollTrigger `scrub` + all-intra MP4/WebM | Poster image + optional autoplay muted loop or still | High bandwidth (8–13 MB+ per clip at 1280px) |
| Canvas image sequence | GSAP ScrollTrigger + canvas | Single still frame | High requests and memory |
| Page transitions | Cross-document View Transitions (`@view-transition`) | Normal navigation | Low |
| Smooth scroll | Native; optionally Lenis 1.3.x, `respectReducedMotion` default | Native scroll | Low–medium (main-thread rAF) |
| WebGL | Only for a single signature moment, if at all | Static image | High (JS + GPU + load time) |
