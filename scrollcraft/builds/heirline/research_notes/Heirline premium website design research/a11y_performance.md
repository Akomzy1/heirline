# Accessibility and Performance for a Premium, Motion-Rich, Scroll-Driven Marketing Site (2025-2026)

Audience context: affluent users aged 50+, many on iPhones, on Nigerian mobile networks (variable 4G), plus UK/US/UAE diaspora. Research date: November 2026.

Source-quality note: items marked "(not re-fetched this session)" are established documentation the researcher cites from known pages but did not re-open during this session. Verify exact wording before quoting.

---

## 1. prefers-reduced-motion: remove vs replace; WCAG 2.3.3 and 2.2.2; vestibular guidance on parallax and scroll-jacking

### Takeaway
WCAG 2.2.2 (Level A, so it is mandatory) requires a pause/stop/hide control for any auto-starting motion that lasts more than 5 seconds alongside other content. That covers looping hero and background video. WCAG 2.3.3 (Level AAA) asks that non-essential motion triggered by interaction, including scroll-linked parallax, can be turned off. Under reduced motion, remove known vestibular triggers (parallax, scaling and zooming, spinning, 2.5D plane shifts, peripheral motion near text) and replace them with fades, crossfades or still frames. Do not remove everything: that keeps the meaning and the premium feel.

### Cited Findings
**WCAG 2.3.3 Animation from Interactions (AAA)**
- Level AAA. Intent: "to allow users to prevent animation from being displayed on web pages." Motion started automatically by the page falls under 2.2.2 instead. — [W3C Understanding 2.3.3](https://www.w3.org/WAI/WCAG22/Understanding/animation-from-interactions.html)
- Motion animation is defined as "addition of steps between conditions to create the illusion of movement or to give a sense of a smooth transition." Changes to colour, blur or opacity alone do not count as motion unless they change perceived size, shape or position. — [W3C Understanding 2.3.3](https://www.w3.org/WAI/WCAG22/Understanding/animation-from-interactions.html)
- Implication: opacity crossfades are the W3C-sanctioned safe replacement. Note that WebKit separately lists *animated blur* as a possible zoom-like trigger (see below).
- Parallax is defined as "backgrounds move at a different rate to foregrounds." The worked example is decorative elements sliding horizontally on vertical scroll, with a site-wide setting to turn the extra motion off. — [W3C Understanding 2.3.3](https://www.w3.org/WAI/WCAG22/Understanding/animation-from-interactions.html)
- "Moving new content into the viewport is essential for scrolling." User-controlled scrolling itself is allowed. Added non-essential scroll animation must be possible to disable. — [W3C Understanding 2.3.3](https://www.w3.org/WAI/WCAG22/Understanding/animation-from-interactions.html)
- Vestibular reactions "include dizziness, nausea and headaches", and they can be severe enough to require bed rest. — [W3C Understanding 2.3.3](https://www.w3.org/WAI/WCAG22/Understanding/animation-from-interactions.html)
- Sufficient techniques: C39 (CSS `prefers-reduced-motion`), SCR40 (`prefers-reduced-motion` in JS via matchMedia), and a user-set preference that prevents animation. — [W3C Understanding 2.3.3](https://www.w3.org/WAI/WCAG22/Understanding/animation-from-interactions.html)

**WCAG 2.2.2 Pause, Stop, Hide (Level A)**
- Level A. It is a non-interference criterion: failing content "can interfere with a user's ability to use the whole page." — [W3C Understanding 2.2.2](https://www.w3.org/WAI/WCAG22/Understanding/pause-stop-hide.html)
- It applies to moving, blinking or scrolling content that (1) starts automatically, (2) lasts more than 5 seconds and (3) runs in parallel with other content. Such content needs "a mechanism for the user to pause, stop, or hide it." — [W3C Understanding 2.2.2](https://www.w3.org/WAI/WCAG22/Understanding/pause-stop-hide.html)
- "Starts automatically" also covers motion triggered indirectly by hovering, focusing or *scrolling an element into view*. — [W3C Understanding 2.2.2](https://www.w3.org/WAI/WCAG22/Understanding/pause-stop-hide.html)
- Auto-updating content (for example an auto-advancing carousel) has no 5-second exception. — [W3C Understanding 2.2.2](https://www.w3.org/WAI/WCAG22/Understanding/pause-stop-hide.html)
- The control must not "tie up the user or the focus". Pause-only-while-focused does not qualify. A single control for all moving elements is recommended. — [W3C Understanding 2.2.2](https://www.w3.org/WAI/WCAG22/Understanding/pause-stop-hide.html)
- Synchronized media and motion pictures count as moving content. A preloader is exempt if users cannot interact during it. — [W3C Understanding 2.2.2](https://www.w3.org/WAI/WCAG22/Understanding/pause-stop-hide.html)

**Vestibular triggers and remove-vs-replace (WebKit, James Craig, May 2017; still the canonical taxonomy)**
- Five trigger classes:
  1. Scaling and zooming (animated blur can do the same)
  2. Spinning and vortex
  3. Multi-speed or multi-directional movement (parallax)
  4. Dimensionality or plane shifting (2.5D)
  5. Peripheral motion, especially near text
  — [WebKit: Responsive Design for Motion](https://webkit.org/blog/7551/responsive-design-for-motion/)
- Apple's own examples:
  - **Remove** scaling poster and background video motion, spinning backgrounds and scroll-triggered image offsets.
  - **Replace** a 3D zoom and blur with a simpler scroll view that keeps the design intent.
  - **Replace** a tilting 2.5D object with a still image.
  - **Make stationary** floating decorative elements near text.
  - **Keep** predictable direct manipulation such as pinch-zoom.
  — [WebKit](https://webkit.org/blog/7551/responsive-design-for-motion/)
- "Only remove the animations you *know* to be vestibular triggers." Over-removing makes a site "unnecessarily boring". Where motion carries meaning, use a simpler alternate animation. — [WebKit](https://webkit.org/blog/7551/responsive-design-for-motion/)
- Practitioner guidance: a fade-in "can look just as polished" as parallax and avoids triggering users. — [Craft CMS: Designing for reduced motion](https://craftcms.com/blog/designing-for-reduced-motion)
- Scroll-jacking (custom scroll speeds or directions, hijacked scroll events) is listed with multi-layer parallax and looping background motion as a common trigger. — [Front-End Checklist: parallax effects](https://frontendchecklist.io/rules/accessibility/parallax-effects) (secondary source)
- "No-motion-first" pattern: base styles are static, and motion is added only inside `@media (prefers-reduced-motion: no-preference)`. — [Tatiana Mac](https://tatianamac.com/posts/prefers-reduced-motion/)
- With JS-driven motion (GSAP, React), the preference must be read at runtime. In React the first render does not yet know it. — [Josh Comeau](https://joshwcomeau.com/react/prefers-reduced-motion/)

### Inferences
- Concrete reduced-motion mapping for a cinematic scroll site:
  - Scroll-scrubbed hero video becomes a single poster frame, or a 2-3 frame crossfade on section change (opacity only).
  - Parallax layers become flat, with all layers locked to scroll speed 1.0.
  - Scale and zoom-in reveals become opacity fades of 200-300 ms, or instant.
  - Pinned horizontal scroll becomes normal vertical stacking.
  - Smooth-scroll smoothing is disabled (Lenis does this by default, see section 2).
  - Looping ambient video is paused on its poster.
  - Text-reveal per-word translate becomes a plain fade.
  - Cursor-follow and peripheral drift are removed.
  - Keep: colour and opacity transitions, focus-ring transitions, user-triggered disclosure.
- Because 2.2.2 is Level A, any autoplaying looping hero or ambient video longer than 5 seconds needs a visible, keyboard-operable pause button that is not focus-dependent. This applies whether or not the user has reduced motion set. Scroll-scrubbed video (no motion without user scroll) is arguably user-controlled under 2.3.3, but it is still a vestibular trigger if it zooms or parallaxes.
- Offer an on-page "Reduce motion" toggle (the W3C "user-set preference" technique). Many 50+ users will not know the OS setting exists. Persist the choice in localStorage.
- Outdated advice to flag: the blanket `* { animation: none !important; transition: none !important }` reset. It breaks meaning-carrying transitions and can cause transitionend/JS deadlocks. Prefer targeted replacement per WebKit's guidance.

### Gaps
- No primary source found quantifying what share of users 50+ enable Reduce Motion on iOS.
- Adrian Roselli and Scott O'Hara articles on parallax and smooth scroll specifically were not surfaced by search this session.

---

## 2. Smooth-scroll hijacking (Lenis and similar): keyboard, screen readers, find-in-page, anchor links

### Takeaway
Modern Lenis (v1.3.x) is a "native" smoother. It animates the real document scroll position rather than translating a fake container, so sticky positioning, scrollbars, keyboard and screen-reader scrolling largely keep working. Anchors are off by default, though, and the library is capped to 60 fps in Safari and 30 fps in Low Power Mode. Older transform-based smoothers (Locomotive Scroll v4, ScrollSmoother-style wrappers) broke find-in-page and are outdated for accessible builds.

### Cited Findings
- Current version is `lenis@1.3.27`. Lenis "wraps the browser's own scroll, so position: sticky, anchor links, and accessibility keep working." — [Lenis GitHub README](https://github.com/darkroomengineering/lenis)
- Defaults:
  - `smoothWheel: true`, `lerp: 0.1`, `duration: 1.2` (unused when lerp is set)
  - `syncTouch: false` (touch keeps native momentum scrolling; enabling it "can be unstable on iOS<16")
  - `touchMultiplier: 1`, `autoRaf: false`
  - `anchors: false`
  - `allowNestedScroll: false` (warned as a possible performance cost)
  — [Lenis README](https://github.com/darkroomengineering/lenis)
- Anchor links: "Lenis will prevent anchor links from working while scrolling." Set `anchors: true` (accepts ScrollToOptions, for example an offset for a sticky header). — [Lenis README](https://github.com/darkroomengineering/lenis)
- `respectReducedMotion` defaults to true. Under reduced motion, smoothing is disabled and programmatic scrolls jump instantly. The README advises against opting out. — [Lenis README](https://github.com/darkroomengineering/lenis)
- Listed limitations:
  - No CSS scroll-snap (use `lenis/snap` instead)
  - "capped to 60fps on Safari" and "30fps on low power mode"
  - Smooth scroll stops over iframes
  - position: fixed lag on pre-M1 macOS Safari
  - Nested scrollers need `data-lenis-prevent` (variants: `-wheel`, `-touch`, `-vertical`, `-horizontal`)
  - Import `lenis/dist/lenis.css`
  — [Lenis README](https://github.com/darkroomengineering/lenis)
- The README does not discuss keyboard navigation or find-in-page explicitly. — [Lenis README](https://github.com/darkroomengineering/lenis)
- With GSAP ScrollSmoother (transform-based), a tester reported that keyboard tabbing "seems to work pretty well" but "CTRL+F to find (and jump to) content within a page does not." — [GSAP forum](https://greensock.com/forums/topic/34032-scrollsmoother-accessibility/)
- CSS `scroll-behavior: smooth` on `html` also smooths find-in-page jumps. A common fix scopes it to `html:focus-within`. — [Digital Thrive: Fixing smooth scrolling with find on page](https://www.digitalthriveai.com/en-us/resources/ui-ux/fixing-smooth-scrolling-with-find-on-page/) (secondary source)
- A skills-directory summary claims Lenis native mode keeps the native scrollbar and find-in-page and only smooths the rate of scrollY change. — [skills.sh Lenis entry](https://www.skills.sh/avnehsbhatia/ultraui/lenis-smooth-scroll) (low authority; not confirmed in Lenis docs)

### Inferences
- Lenis setup checklist:
  - `new Lenis({ anchors: { offset: -headerHeight }, autoRaf: true })`, leaving `respectReducedMotion` on.
  - Leave `syncTouch` off, so iOS keeps native touch momentum. This matters for your iPhone-heavy audience.
  - Add `data-lenis-prevent` to modals, menus and scrollable panels.
  - Drive GSAP ScrollTrigger from Lenis's `scroll` event.
  - Do not use CSS scroll-snap with Lenis.
- Keyboard: because Lenis animates real scroll, Space, PageDown and arrow keys still work. Test that focus-into-view (Tab to an off-screen link) is not fought by an in-flight lerp. If it is, call `lenis.scrollTo(el, { immediate: true })` on focusin, or stop Lenis while the keyboard is in use.
- Find-in-page: with native-scroll smoothers the browser jumps the real scroll, so it should work. It must be tested, though, especially where content is hidden by scroll reveal (opacity 0 text is "found" but invisible; see section 3).
- Because the Safari cap is 60 fps (30 in Low Power Mode) and most of the audience is on iPhone, the wheel-smoothing benefit applies mainly to desktop diaspora users. Mobile users get native scroll anyway. Consider enabling Lenis only on `(pointer: fine)` devices.
- Outdated: Locomotive Scroll v4 and other `transform: translate3d` virtual-scroll containers. They break find-in-page, sticky positioning, native scrollbar, and screen-reader virtual cursor scroll sync. Locomotive Scroll v5 docs exist ([scroll.locomotive.ca](https://scroll.locomotive.ca/docs/)) and are reportedly built on Lenis, but this was not verified this session.

### Gaps
- No primary-source test results found for Lenis with VoiceOver iOS, VoiceOver macOS or NVDA. Recommend in-house testing.
- Not verified whether Lenis's `anchors` option moves keyboard focus to the target (native anchor navigation does). Likely you need to focus the target manually for screen-reader users.

---

## 3. Pinned and sticky sections: focus order and screen-reader reading order with scroll-revealed content

### Takeaway
Screen readers and Tab order follow DOM order, not visual or scroll order. In every pinned "chapter" the DOM must hold the full narrative in reading order, with all text present and readable at all times. Scroll should only change visual emphasis. Sticky headers and pinned layers must not cover focused elements (WCAG 2.2 SC 2.4.11, AA).

### Cited Findings
- Screen readers follow DOM order, not visual position. WCAG 2.4.3 requires focus order that preserves meaning. — [DubBot: Gettin' out of a sticky situation (2025)](https://dubbot.com/dubblog/2025/gettin-out-of-a-sticky-situation.html); [BOIA: sticky and fixed elements](https://www.boia.org/blog/how-sticky-and-fixed-elements-impact-accessibility)
- Sticky headers can cover focused elements. Fix with `scroll-padding-top`. JS that re-renders a sticky menu on scroll can make keyboard focus jump backward. — [DEV: Sticky header accessibility](https://dev.to/agentkit/sticky-header-accessibility-the-skip-link-focus-and-reflow-problems-most-sites-miss-181n) (secondary source)
- HTML source order vs CSS display order: visual reordering (grid, absolute positioning) diverges from what assistive tech reads. — [Adrian Roselli (2015)](https://adrianroselli.com/2015/10/html-source-order-vs-css-display-order)
- Chrome's CSS `reading-flow` property aligns sequential focus navigation with visual order in grid and flex layouts. It is Chromium-only. — [Chrome for Developers: reading-flow](https://developer.chrome.com/blog/reading-flow)
- Scrollytelling guidance recommends CSS `position: sticky` over JS scroll listeners for pinned visuals. — [skills.sh scrollytelling](https://skills.sh/doodledood/claude-code-plugins/scrollytelling) (low authority)
- WCAG 2.2 SC 2.4.11 Focus Not Obscured (Minimum), Level AA: a focused component must not be entirely hidden by author-created content such as sticky headers or overlays. — [W3C Understanding 2.4.11](https://www.w3.org/WAI/WCAG22/Understanding/focus-not-obscured-minimum.html) (not re-fetched this session)

### Inferences
- Pattern for a pinned section:
  - Use one `<section>` with a heading, and put the sticky visual (`aria-hidden="true"` if purely decorative, or a single `role="img"` with an `aria-label` summarising it) before or after the text steps.
  - Write the text steps as ordinary block elements in narrative order.
  - Scroll scrubs only the visual and the emphasis (opacity, from about 0.4 to 1), never `display:none` or `visibility:hidden` on text the user needs.
- Avoid opacity-0 "reveal" for real text. Screen readers and find-in-page will reach invisible text, and a sighted keyboard user tabbing to an invisible link gets a WCAG 2.4.7 focus-visible failure. If you must reveal, make it a short in-viewport transition (IntersectionObserver), and make focus force the revealed state with `:focus-within`.
- Horizontal pinned galleries that translate content: make sure Tab into an off-screen card scrolls the pinned track to it. On `focusin`, compute the progress and call `lenis.scrollTo` or `ScrollTrigger.scroll()`. Otherwise focus lands off-canvas (2.4.11 failure).
- Set `scroll-padding-top` equal to the sticky header height on `html`, so anchor, Tab and find-in-page targets are not covered.
- Provide a "Skip intro animation" or "Skip to content" link before long pinned hero sequences. A 300-500vh pinned hero is a long keyboard and screen-reader trek.
- Do not depend on `reading-flow`. Safari and Firefox lack it, and the iPhone audience is on WebKit.

### Gaps
- No authoritative tested study found on VoiceOver behaviour inside long `position: sticky` pinned sections (for example whether virtual cursor movement scrolls the page enough to trigger ScrollTrigger states). In-house testing is needed.

---

## 4. Readability for older users: body size, contrast, text over imagery and video, serif display legibility

### Takeaway
For a 50+ luxury audience, use body text of at least 18-19px (do not go below 16px), line-height of about 1.5, and aim for AAA contrast (7:1) on body copy. Treat AA (4.5:1 for body, 3:1 for large text) as a hard floor. Put text over imagery or video only on a scrim that guarantees contrast against the brightest frame. Reserve high-contrast thin-hairline serifs (Didone styles) for large display sizes only.

### Cited Findings
- HHS health-literacy guide: use at least 16px. "If you're creating content for older adults or people with vision problems, consider using an even larger font size — 19 pixels or 14 points." — [HHS Health Literacy Online 5.3](https://odphp.health.gov/healthliteracyonline/design-easy-scanning/use-readable-font-thats-least-16-pixels)
- NN/g: readability "has remained an issue for seniors throughout all our studies over the years". All sites should let users increase text size as desired. — [NN/g: Usability for seniors](https://www.nngroup.com/articles/usability-seniors-improvements/)
- W3C WAI: many older people require large text due to declining vision, including text in form fields and controls. — [W3C WAI older users draft](https://www.w3.org/WAI/EO/Drafts/sites-older-users/Overview.html)
- Contrast thresholds (not re-fetched this session):
  - WCAG 1.4.3 Contrast (Minimum), AA: 4.5:1 for normal text and 3:1 for large text (at least 24px regular, or at least 18.66px bold). — [W3C Understanding 1.4.3](https://www.w3.org/WAI/WCAG22/Understanding/contrast-minimum.html)
  - WCAG 1.4.6 Contrast (Enhanced), AAA: 7:1 normal and 4.5:1 large. — [W3C Understanding 1.4.6](https://www.w3.org/WAI/WCAG22/Understanding/contrast-enhanced.html)
  - WCAG 1.4.11 Non-text Contrast, AA: 3:1 for UI components and focus indicators. — [W3C Understanding 1.4.11](https://www.w3.org/WAI/WCAG22/Understanding/non-text-contrast.html)
- WCAG 1.4.4 Resize Text (AA): text must scale to 200% without loss of content. WCAG 1.4.12 Text Spacing (AA): layouts must tolerate line-height 1.5 and paragraph spacing 2x. — [W3C Understanding 1.4.4](https://www.w3.org/WAI/WCAG22/Understanding/resize-text.html); [W3C Understanding 1.4.12](https://www.w3.org/WAI/WCAG22/Understanding/text-spacing.html) (not re-fetched this session)

### Inferences
- Concrete type scale:
  - Body: `font-size: clamp(1.125rem, 1rem + 0.4vw, 1.25rem)` (18-20px), line-height 1.5-1.6, measure 60-72ch.
  - Captions and legal: at least 16px.
  - Buttons: at least 18px with a hit area of at least 44x44 CSS px. WCAG 2.5.8 AA minimum is 24x24 (not re-fetched); Apple HIG uses 44pt.
  - Use `rem` everywhere so iOS Dynamic Type / browser zoom scales it. Never set `maximum-scale=1` or `user-scalable=no` in the viewport meta tag.
- Luxury palettes often fail contrast: gold on cream, grey on black, and thin ivory text on mid-tone photography. Check gold and champagne accent text with a contrast tool. Many "brand golds" (for example #C9A96E on #FFFFFF, about 2.3:1) fail even AA large. Use gold for rules, ornaments and large display only. Body text should be near-black on ivory, or ivory on near-black, at 7:1 or above.
- Text over video or imagery: WCAG contrast must hold against *every* frame behind the text. Practical recipe:
  - A bottom or side gradient scrim, for example `linear-gradient(to top, rgb(0 0 0 / .72) 0%, rgb(0 0 0 / .45) 40%, transparent 70%)`.
  - Or a solid panel behind text at 0.6-0.8 opacity.
  - Plus a `text-shadow` of 0 1px 2px rgb(0 0 0 / .5) as a backstop.
  - Measure contrast against the lightest pixel region in the text zone across the clip.
  - Art-direct mobile crops so faces and highlights are not behind copy.
- Serif display: high-contrast Didone and thin display serifs lose their hairlines at small sizes and on non-Retina Android screens. Use the display cut only at 32px and above, and set body in a text-optimised serif or sans with a large x-height and moderate stroke contrast. Avoid light weights (300 or below) for anything under 24px. Avoid all-caps with tight tracking for long lines. Add `letter-spacing: 0.02-0.05em` to small caps labels.
- Do not rely on hover for anything. Many 50+ users browse on iPad and iPhone.

### Gaps
- No peer-reviewed source found this session on the legibility of specific high-contrast serifs for older readers. The serif recommendations above are typographic convention, not cited research.
- The WCAG 3 / APCA contrast model is still a working draft. It is not a conformance target in 2026. Not researched this session.

---

## 5. Mobile art direction and iOS Safari touch-scrolling behaviour

### Takeaway
Ship separate portrait crops and clips through `<picture>` / `<source media>` for images, and choose the video source with JS or `matchMedia`. Size full-screen heroes with `100svh` (stable, fits on load), not `100dvh` (re-lays out during scroll as the toolbar moves) and not legacy `100vh`. Leave iOS touch scrolling native.

### Cited Findings
- `dvh` updates in real time as the address bar and toolbar show or hide. WebKit bug 266835 documents "dvh causes scroll jank as the address bar resizes when scrolling" (iOS 17). — [WebKit Bug 266835](https://bugs.webkit.org/show_bug.cgi?id=266835)
- Recommended: `100svh` for full-screen sections that must fit the visible screen on load. Reserve `dvh` for intentional dynamic resizing. — [Ahmad Shadeed: New viewport units](https://ishadeed.com/article/new-viewport-units/); [OpenReplay: fix 100vh](https://blog.openreplay.com/fix-100vh-mobile-viewport/)
- svh, lvh and dvh are supported in Chrome 108+, Safari 15.4+ and Firefox 101+. — [OpenReplay](https://blog.openreplay.com/understanding-dynamic-viewport-units-css/) (secondary source)
- WebKit bug report: svh and lvh are incorrect in third-party iOS browsers on iOS 18. — [WebKit Bug 279998](https://bugs.webkit.org/show_bug.cgi?id=279998)
- WebKit bug report: a fixed-position element taller than the viewport is cropped to 100dvh. — [WebKit Bugzilla 261185](https://www2.webkit.org/show_bug.cgi?id=261185)
- Three.js canvas "jumps" on mobile when the address bar hides or shows if it is sized to 100vh. — [three.js forum](https://discourse.threejs.org/t/three-js-canvas-jumps-on-mobile-when-address-bar-hides-shows-100vh-issue/87435)
- Lenis `syncTouch` is off by default (native touch scroll), and enabling it can be unstable on iOS below 16. — [Lenis README](https://github.com/darkroomengineering/lenis)

### Inferences
- Image art direction:
  ```html
  <picture>
    <source media="(orientation: portrait) and (max-width: 767px)" type="image/avif" srcset="hero-portrait-828.avif 828w, hero-portrait-1290.avif 1290w" sizes="100vw">
    <source media="(orientation: portrait) and (max-width: 767px)" type="image/webp" srcset="...">
    <source type="image/avif" srcset="hero-land-1600.avif 1600w, hero-land-2560.avif 2560w" sizes="100vw">
    <img src="hero-land-1600.jpg" width="1600" height="900" alt="..." fetchpriority="high" decoding="async">
  </picture>
  ```
  Give each crop its own intrinsic `width` and `height`. Since 2023, `<source>` elements accept `width` and `height` for per-crop aspect ratio, which avoids CLS between crops (not verified this session).
- Video art direction: `<video><source media>` is honoured by Safari and was re-added to Chromium in 2023. Firefox support was not verified this session, so selecting the src in JS with `matchMedia('(orientation: portrait)')` is the safest cross-browser route. Encode a separate 9:16 or 4:5 portrait clip (for example 720x1280) rather than centre-cropping a 16:9 clip with `object-fit: cover`. A portrait crop also cuts pixel count, and therefore bytes.
- Pinned scroll sections on iOS: compute ScrollTrigger lengths in `svh`, or call `ScrollTrigger.config({ ignoreMobileResize: true })`. This stops address-bar resizes from recalculating pins mid-scroll. The GSAP option name is from GSAP docs and was not re-fetched.
- Use `height: 100svh` with an `@supports not (height: 1svh) { height: 100vh }` fallback. Keep `100dvh` only for overlay menus that must track the toolbar.
- Do not attach `touchmove` handlers with `preventDefault`. Mark scroll listeners `{ passive: true }`. Do not set `overscroll-behavior: none` on `body`: it kills pull-to-refresh, which older users rely on.

### Gaps
- Not verified this session: current Firefox support for `<video><source media>`.
- Not verified on iOS 26 whether the WebKit dvh jank bug persists, or whether Safari 26's redesigned compact tab bar changes svh/lvh values.

---

## 6. Scroll-scrubbed video: encoding, codecs, iOS autoplay and Low Power Mode, preload, and image sequences on canvas

### Takeaway
For scrubbing, encode short all-intra or near-intra clips: H.264 High, yuv420p, `-g 1` (or a keyint of 2-6 to trade a little precision for 2-3x smaller files), faststart, no audio, scaled to the largest rendered size (about 1280 px desktop, about 720-828 px wide portrait mobile), 24-30 fps. Ship WebM (VP9 or AV1) first, then an H.264 MP4 fallback for Safari. Expect Low Power Mode on iOS to block autoplay. For short hero sequences that must be frame-exact on iPhone, an image sequence drawn to `<canvas>` is often more reliable than seeking `<video>`.

### Cited Findings
**Encoding**
- `-g 1` makes every frame a keyframe, "so every seek is exact". Normal encodes place one every 2-10 s (250 frames is a common default). — [Hon Tran: Scroll-scrubbed video stutters fix (Jul 2026)](https://www.hontran.dev/blog/scroll-scrubbed-video-stutters-fix)
- Recommended settings:
  - `scale=1280:-2` (match the largest rendered size, never larger), `-r 30`, `-pix_fmt yuv420p` (otherwise Safari can show a black box), `-an`
  - MP4: `libx264 -crf 23 -movflags faststart`
  - WebM: `libvpx-vp9 -crf 32 -b:v 0 -row-mt 1`
  - Use `preload="auto"`, since frames must be buffered to seek. Do not throttle or debounce seeks.
  — [Hon Tran (2026)](https://www.hontran.dev/blog/scroll-scrubbed-video-stutters-fix)
- Illustrative sizes:
  - All-intra about 1280 px at 30 fps: about 8 MB MP4 and about 13 MB WebM, against about 1-2 MB for a normal encode
  - A 1080p all-intra clip can exceed 100 MB
  — [Hon Tran (2026)](https://www.hontran.dev/blog/scroll-scrubbed-video-stutters-fix)
- A full command example: `ffmpeg -i in.mov -vf scale=1280:-2 -r 30 -movflags faststart -vcodec libx264 -crf 23 -g 1 -pix_fmt yuv420p -an out.mp4`. — [Muffin Man: Scrubbing videos using JavaScript](https://muffinman.io/blog/scrubbing-videos-using-javascript/)
- File size grows 3-5x with all-intra. — [Framer Frame Scrub component](https://www.framer.com/community/marketplace/components/frame-scrub/)
- A keyint between 1 and 10 improves scrubbing precision at a file-size cost. A demo uses `-keyint_min 6 -g 6` at 1080p or below and 30 fps or below. — [Maglr help](https://help.maglr.com/en/article/preparing-your-video-for-scrub-on-scroll-1o5jbvr/); [CodePen demo](https://codepen.io/luis-lessrain/pen/zxGjErP)
- Firefox seeks VP9 "beautifully". Safari doesn't reliably play VP9, so list WebM first and fall back to MP4. — [Hon Tran (2026)](https://www.hontran.dev/blog/scroll-scrubbed-video-stutters-fix)

**Codecs**
- web.dev:
  - AV1 in WebM usually compresses best but has less support.
  - VP9 has broader support but makes larger files.
  - Put WebM first with `type` attributes and H.264 MP4 as the fallback ("near-universal" support).
  - Strip audio with `-an`, which shrinks files even if the audio is silent.
  — [web.dev Learn Performance: Video](https://web.dev/learn/performance/video-performance)
- Safari AV1 (Safari 17+) works only on devices with hardware decode: iPhone 15 Pro (A17 Pro) and later, M3+ Macs and M4 iPad Pro. The A18 iPhone 16 line also decodes it. Whether Safari has a software fallback on older devices is disputed between sources. — [Bitmovin: Apple AV1 support](https://bitmovin.com/apple-av1-support); [TestMu AI](https://www.testmuai.com/learning-hub/av1-browser-support/); contradicted by [Discourse Meta thread](https://meta.discourse.org/t/eta-on-safari-playback-issues/388277)
- HEVC: the iPhone 6s was the first iOS device with HEVC hardware decode. — [Bitmovin](https://bitmovin.com/apple-av1-support)

**Autoplay, Low Power Mode and preload**
- Background or GIF-style video: `autoplay muted loop playsinline`. Autoplaying videos download immediately "even if they are located outside of the initial viewport." — [web.dev](https://web.dev/learn/performance/video-performance)
- Use `preload="none"` for user-started video, `metadata` for duration only. Preload is a hint, and browsers may ignore it. By default the download starts when the parser meets `<video>`. — [web.dev](https://web.dev/learn/performance/video-performance)
- Low Power Mode on iOS disables video autoplay even when muted, and shows native play controls. WebKit bug 216887 ("Low Power mode is disabling video autoplay", filed 2020) remains open, and bug 219889 covers controls appearing. — [WebKit Bug 216887](https://bugs.webkit.org/show_bug.cgi?id=216887); [WebKit Bug 219889](https://bugs.webkit.org/show_bug.cgi?id=219889); [Veriff known issues](https://devdocs.veriff.com/docs/known-issues)
- Recommended handling: call `video.play()` and catch the rejected promise, then fall back to a still image. Hiding the native play-button overlay via CSS pseudo-elements no longer works reliably. — [lesniakrafal guide](https://lesniakrafal.pages.dev/en/article/how-to-enable-autoplay-video-in-low-power-mode-on-ios-and-macos); [Veriff](https://devdocs.veriff.com/docs/known-issues)
- Lenis is capped at 30 fps in Low Power Mode on Safari. — [Lenis README](https://github.com/darkroomengineering/lenis)

**CSS scroll-driven animations**
- Safari 26.0 shipped CSS scroll-driven animations (`animation-timeline: scroll()` and `view()`). — [WebKit: Features in Safari 26.0](https://webkit.org/blog/17333/webkit-features-in-safari-26-0/); [WebKit guide to scroll-driven animations](https://www.webkit.org/blog/17101/a-guide-to-scroll-driven-animations-with-just-css/)
- Safari 26.5 fixed view-timeline progress errors near the 0% and 100% thresholds. — [Safari 26.5 release notes](https://developer.apple.com/documentation/safari-release-notes/safari-26_5-release-notes.md)
- An open WebKit bug ties a `translate` keyframe issue to the threaded path added in 26.4. — [WebKit Bug 327193](https://bugs.webkit.org/show_bug.cgi?id=327193)
- Firefox had no production support as of early 2026, per a secondary source. — [buildmvpfast](https://www.buildmvpfast.com/blog/css-scroll-driven-animations-replace-js-2026) (secondary source; verify against [web-features explorer](https://web-platform-dx.github.io/web-features-explorer/features/scroll-driven-animations))

### Inferences
- Recommended scrub-video spec (desktop and landscape):
  - 1280x720, 24-30 fps, 3-6 s clip (72-180 frames)
  - H.264 High@4.1, `-crf 23-26`, `-g 1` (or `-g 4 -keyint_min 4 -sc_threshold 0` for about 2-3x smaller files), `-pix_fmt yuv420p -movflags +faststart -an`
  - Plus WebM VP9 `-crf 32-36 -b:v 0 -g 1 -row-mt 1`
  - Target 4 MB or less per clip
- Portrait mobile spec: 720x1280 (or 828x1472 for Retina), same settings, target 3 MB or less.
- AV1 (`libsvtav1`) helps Android Chrome and the newest iPhones. iPhone 15 and older non-Pro devices still fall back to H.264. Order: AV1 WebM, then VP9 WebM, then H.264 MP4.
- HEVC is not worth adding for scrub, because Safari will take H.264 anyway. HEVC-with-alpha is the only case where it earns its place.
- When to use an image sequence on canvas instead of video:
  - (a) Frame-exact scrubbing on iOS Safari, where `currentTime` seeks are asynchronous and can lag.
  - (b) Very short sequences of about 60-120 frames.
  - (c) When you need transparency.
  - (d) When the Low Power Mode autoplay block or the play-button overlay is unacceptable. Canvas is not affected by video autoplay policy.
- Image-sequence budget: about 90 frames of AVIF or WebP at 1280 wide and roughly 25-40 KB each comes to about 2.5-3.5 MB. Load the first frame eagerly (as the LCP and poster), then progressively load every 4th frame first and fill in, decoding with `createImageBitmap`. On `Save-Data` or slow connections, load only keyframes, or the single poster.
- Always ship a static poster or first frame. Under Low Power Mode, reduced motion or Save-Data, show the poster plus a crossfade to a few stills, not a broken or blank video.
- Gate loading of scrub assets until the section is within about 1-2 viewports (IntersectionObserver `rootMargin: "100% 0px"`), except the hero.
- Prefer CSS scroll-driven animations for simple transforms and opacity (they run off the main thread where threaded, which helps INP), wrapped in `@supports (animation-timeline: scroll())` with a GSAP fallback. Keep video-seek scrubbing in JS.
- Outdated: "use GIFs for ambient loops" (web.dev says replace with video), and "use 1080p or 4K scrub video" (size explodes with all-intra).

### Gaps
- No Apple or WebKit-blog primary document found this session that states the current (iOS 26) Low Power Mode autoplay policy. Evidence is from bug reports and developer notes.
- No authoritative benchmark found comparing canvas image-sequence vs all-intra video scrub smoothness on recent iPhones.
- `requestVideoFrameCallback` and blob-prefetch techniques were not covered by the sources fetched.

---

## 7. Core Web Vitals 2026 (LCP, INP, CLS) for hero-video and image-heavy pages

### Takeaway
"Good" means, at the 75th percentile of field data: LCP of 2.5 s or less, INP of 200 ms or less, CLS of 0.1 or less. INP replaced FID in March 2024. For a video hero, the poster or first frame is the LCP candidate. Preload it with `fetchpriority="high"` and never lazy-load it. Reserve dimensions for every image and video to protect CLS. Keep scroll handlers and heavy JS off the main thread to protect INP.

### Cited Findings
- A `<video>` poster is an LCP candidate. If the poster is the LCP element, use `<link rel="preload" as="image" href="poster.jpg" fetchpriority="high">`. Preloading a poster that is not the largest element can slow LCP by competing for bandwidth. — [web.dev: Video performance](https://web.dev/learn/performance/video-performance)
- Without a poster, the first video frame can be the LCP candidate, whichever of poster or first frame paints earlier. — [corewebvitals.io: LCP](https://corewebvitals.io/core-web-vitals/largest-contentful-paint)
- Use high priority on only one or two critical preloads, or the boost is diluted. — [Chrome for Developers: Optimize preload priority](https://developer.chrome.com/docs/modern-web-guidance/guides/performance/optimize-preload-priority)
- Never lazy-load the LCP image. 2025 Web Almanac: only 17% of mobile pages with an LCP image use `fetchpriority="high"`. — [corewebvitals.io](https://corewebvitals.io/core-web-vitals/largest-contentful-paint)
- `loading="lazy"` on video defers poster and metadata. For more control, use a low-quality first-frame poster plus IntersectionObserver to start the download on entry. — [web.dev](https://web.dev/learn/performance/video-performance)
- YouTube embeds blocked the main thread for more than 1.7 s for the median site, which hurts INP. Use a facade. — [web.dev](https://web.dev/learn/performance/video-performance)
- Thresholds (p75): LCP 2.5 s or less, INP 200 ms or less, CLS 0.1 or less. INP replaced FID as a Core Web Vital in March 2024. — [web.dev: Web Vitals](https://web.dev/articles/vitals); [web.dev: INP](https://web.dev/articles/inp) (not re-fetched this session)
- Font best practice: self-host WOFF2, preload only the one or two critical fonts (with `crossorigin`), use `font-display: swap` or `optional`, subset via `unicode-range`, and use size-adjust or fallback metric overrides to cut CLS. — [web.dev: Best practices for fonts](https://web.dev/articles/font-best-practices) (not re-fetched this session)

### Inferences
- Hero checklist:
  - **Hero visual:** the poster (AVIF, with WebP and JPEG fallbacks, portrait and landscape art-directed) is the LCP element. Preload it with `fetchpriority="high"` and `media` attributes matching the `<picture>` sources, so only one crop is preloaded. Keep the poster at 150 KB or less on mobile and 250 KB or less on desktop.
  - **Video loading:** start video download after the `load` event or the LCP paint. Use `preload="none"` plus a JS `src` swap, or `preload="metadata"`. The video should never compete with the poster.
  - **Images:** every `<img>`, `<video>` and `<canvas>` needs `width`/`height` or `aspect-ratio` (CLS). Put `loading="lazy"` and `decoding="async"` on all images below the first viewport, and `fetchpriority="low"` on hero carousel slides 2 and up.
  - **Fonts:**
    - Subset the serif display font to Latin plus the needed diacritics. Include Yoruba, Igbo and Hausa diacritics (ẹ, ọ, ṣ, combining tones) if names or brand copy use them. Check before subsetting.
    - Preload the one display weight used above the fold, and limit total font files to 3 or fewer.
    - Use `font-display: swap` for body and `optional` for the decorative display face, if a fallback flash is acceptable to the brand.
    - Set `size-adjust`, `ascent-override` and `descent-override` on the fallback face to avoid CLS when the display serif swaps in.
  - **INP:** use passive scroll listeners. Do no layout reads in scroll callbacks. Use transform and opacity only. Prefer CSS scroll-driven animations or ScrollTrigger's batched updates. Split long tasks (`scheduler.yield()` where available). Defer analytics and chat widgets until interaction.
  - **Below-the-fold sections:** add `content-visibility: auto` with `contain-intrinsic-size` to long sections to cut rendering cost (verify it does not break pinned ScrollTrigger measurements).
- Outdated: FID (retired 2024); "preload everything"; and `loading="lazy"` on the hero (still common in CMS themes).

### Gaps
- No 2026-specific Google announcement found this session changing CWV thresholds or adding new metrics. Assume 2024 thresholds still apply, but verify on web.dev.
- How Chrome currently treats video first frames as LCP candidates was not verified against a primary Chrome source. The corewebvitals.io claim is secondary.

---

## 8. Performance budgets for slower networks (Nigeria) and adaptive loading (Save-Data, navigator.connection)

### Takeaway
Nigeria's national median mobile download speed was 44.14 Mbps in Ookla's December 2025 Global Index (85th globally). That median hides wide variance in latency, congestion and data cost, and users "feel the pinch of rapid data depletion". Budget the initial view for a slow-4G worst case, not the median. iPhone Safari exposes neither `navigator.connection` nor Save-Data, so adaptive loading must default to light and progressively enhance.

### Cited Findings
- Ookla Speedtest Global Index, December 2025: Nigeria median mobile download 44.14 Mbps, 85th globally, down 7 places. Kenya 45.37 Mbps (80th), South Africa 65.7 Mbps (64th). — [The Guardian Nigeria](https://guardian.ng/business-services/nigerias-internet-speed-slips-ranks-85th-globally/); [BusinessDay](https://businessday.ng/technology/article/nigeria-slips-to-85th-in-global-internet-speed-rankings-as-peers-pull-ahead/) (press reports of Ookla data; Ookla's own page not fetched)
- Ookla H1 2025 operator data: MTN Nigeria 5G median 226.6 Mbps against Airtel 182.6 Mbps. These are 5G-only operator figures, not comparable with the national median. — [TechCabal (Nov 2025)](https://techcabal.com/2025/11/05/mtn-tops-africas-mobile-speed-charts-as-vodacom-leads-5g-race/); [The Condia](https://thecondia.com/mtn-nigeria-fastest-5g-ookla-2025/)
- MTN Nigeria users "feel the pinch of rapid data depletion" despite the top speeds. — [The Condia](https://thecondia.com/mtn-nigeria-fastest-5g-ookla-2025/)
- Network Information API (`navigator.connection`, `effectiveType`) is supported in Chrome and Edge, not in Safari or Firefox. `effectiveType` takes the values `slow-2g`, `2g`, `3g` and `4g`, derived from RTT and downlink, so a high-latency link reports lower. — [web.dev: Adaptive serving based on network quality](https://web.dev/articles/adaptive-serving-based-on-network-quality)
- The `Save-Data` header is sent on all requests when data saver is enabled (Chrome, Opera, Yandex). JS check: `navigator.connection.saveData`. Check it server-side as well, since JS can fail. — [web.dev: Delivering fast and light applications with Save-Data](https://web.dev/articles/optimizing-content-efficiency-save-data)
- Autoplaying videos download immediately even outside the initial viewport. — [web.dev](https://web.dev/learn/performance/video-performance)

### Inferences
- Proposed budgets (compressed, transferred), aimed at LCP of 2.5 s or less at p75 on variable Nigerian 4G and good on UK/US/UAE:
  - **Critical path to LCP:**
    - HTML 30 KB or less, and critical CSS inlined, 15 KB or less
    - 1-2 fonts at 80 KB or less total (subset WOFF2)
    - Hero poster at 150 KB or less on mobile
    - Total under about 300 KB before first render
  - **JS:** 150 KB or less compressed for initial load (GSAP core + ScrollTrigger is about 45-50 KB gzip, and Lenis is small; figures not verified this session). Defer everything else.
  - **Initial page weight** (before user scroll): 1 MB or less on mobile.
  - **Full scroll experience:** 6-8 MB or less on mobile (for example 2 scrub clips at 3 MB or less), loaded progressively. 10-15 MB on desktop broadband.
  - **Per scrub clip:** 3 MB or less mobile portrait, 4-6 MB or less desktop.
  - **Image sequences:** 3 MB or less per sequence.
- Adaptive-loading tiers (detect, then default to "lite" when signals are absent on low-end devices):
  1. **Lite:** triggered by Save-Data, `effectiveType` in [slow-2g, 2g, 3g], `prefers-reduced-motion`, `prefers-reduced-data` (experimental), or a failed `video.play()` (Low Power Mode). Serves posters only, no scrub video, and crossfades.
  2. **Standard:** for 4G mobile, including iPhone where there are no signals. Uses portrait clips at reduced bitrate, loaded on approach.
  3. **Rich:** for desktop with a fine pointer and a fast connection. Uses full-res clips and Lenis smoothing.
- Because Safari reports nothing, a runtime throughput probe is a pragmatic iPhone signal. Time the poster download with the Resource Timing API: transferSize divided by (responseEnd minus responseStart). If the poster took more than about 1 s, stay on lite. This is an inference, not a cited pattern.
- Add a visible "Lite mode / Data saver" toggle in the footer or the motion toggle. Data cost matters in Nigeria even for affluent users roaming between networks.
- CDN: use a CDN with African PoPs (Lagos or Johannesburg) and edge image transforms serving AVIF and WebP. The researcher did not verify specific vendors' Lagos PoPs this session.
- Test in WebPageTest or Lighthouse with throttling around 9 Mbps down and 150 ms RTT ("Slow 4G"-ish) plus a mid-range Android, and on a real iPhone in Low Power Mode.

### Gaps
- Ookla's own Nigeria country page and Opensignal Nigeria reports were not fetched. Median latency and upload figures for Nigeria are missing, and they matter as much as download for LCP.
- No source was found for the distribution (p25 or p10) of Nigerian mobile speeds. The median alone understates tail users.
- Current support for `prefers-reduced-data` and for Safari Save-Data was not verified this session (last known: experimental, unsupported in Safari).
