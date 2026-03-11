# WCAG 2.1 AA Compliance Audit Report

## Executive Summary

An initial audit of the CodeWorkout application reveals several areas where accessibility can be improved to meet WCAG 2.1 Level AA standards. The most critical issues involve missing alternative text for images, lack of form labels, and missing structural elements like language attributes and skip links. Addressing these will significantly improve the experience for screen reader users and keyboard-only navigators.

## 1. HTML Structure & Metadata

### Issues Identified
- **Missing Language Attribute**: The `<html>` tag in `app/views/layouts/header.html.haml` is missing the `lang` attribute. Screen readers need this to correctly pronounce content.
  - *File*: `app/views/layouts/header.html.haml`
  - *Remediation*: Add `lang="en"` to the `%html` tag.
- **Missing "Skip to Content" Link**: There is no mechanism to bypass the navigation menu and jump directly to the main content.
  - *Remediation*: Add a hidden "Skip to content" link as the first focusable element in `app/views/layouts/application.html.haml` that points to `<main id="main">`.
- **Static Page Titles**: The `<title>` tag in `header.html.haml` is static ("CodeWorkout"). It should be unique for each page to help users understand their location.
  - *Remediation*: Use `content_for :title` in views and output it in the layout.

## 2. Images & Non-Text Content

### Issues Identified
- **Missing Alt Attributes**: Several `image_tag` usages lack `alt` attributes. This causes screen readers to read the filename, which is often unhelpful.
  - *Files*:
    - `app/views/exception_handler/exception/show.html.haml`
    - `app/views/course_enrollments/_course_enrollment.html.haml`
    - `app/views/workouts/_workout.html.haml`
    - `app/views/courses/_tab_grades.html.haml`
    - `app/views/exercises/show.html.haml`
    - `app/views/exercises/_exercise.html.haml`
    - `app/views/users/show.html.haml`
    - `app/views/users/_user.html.haml`
    - `app/views/users/_form.html.haml`
    - `app/views/static_pages/thumbnails.html.haml`
  - *Remediation*: Add meaningful `alt` text for informative images. For decorative images (like `pct-blur.png` or `score-blur.png` if strictly visual), use `alt=""` or `aria-hidden="true"`.

## 3. Forms & Input

### Issues Identified
- **Missing Labels**: The search input in `app/views/exercises/_search.html.haml` uses a placeholder but lacks a `<label>` or `aria-label`. Placeholders are not a substitute for labels.
  - *File*: `app/views/exercises/_search.html.haml`
  - *Remediation*: Add a visually hidden `<label>` associated with the input, or add `aria-label="Search exercises"` to the input field.
- **Icon-Only Buttons**: The search button uses an icon (`%i.fa.fa-search`) with text "Search" inside the button tag. This is actually good, provided the text is visible orsr-only. However, if the text is hidden by CSS (not clear from code), it needs valid accessible name.

## 4. Interactive Elements

### Issues Identified
- **Link Accessibility**: The navbar uses `icon_tag_for` inside links without text.
  - *File*: `app/views/layouts/_navbar.html.haml`
  - *Issue*: `link_to icon_tag_for('wrench'), admin_dashboard_path, {label: "Admin Menu Access"}`. The `label` attribute is likely not rendering as a valid accessible name.
  - *Remediation*: Use `aria: { label: "Admin Menu Access" }` instead of `{label: "..."}`.
- **Canvas Accessibility**: The `percentBar` function in `app/assets/javascripts/application.js` draws text on a `<canvas>` element. Content within `<canvas>` is not accessible to screen readers.
  - *File*: `app/assets/javascripts/application.js`
  - *Remediation*: Provide fallback content inside the `<canvas>` tag or use `aria-label`/`aria-labelledby` on the canvas element. Better yet, use standard HTML/CSS progress bars instead of canvas for simple percentage displays.

## 5. Color & Contrast

### Issues Identified
- **Potential Contrast Failures**: The usage of white text on background images (`.home .cta .pitch`) and specific colors like `#efb04f` (orange), `#468847` (green), `#dd514c` (red) in `custom.scss` needs verification against the 4.5:1 contrast ratio required for AA compliance.
  - *File*: `app/assets/stylesheets/custom.scss`
  - *Remediation*: Test all text color combinations against background colors using a contrast checker. Ensure text over images has a solid background or text shadow to ensure readability. **(Manual verification with a contrast checker is required for these elements.)**

## Next Steps

1.  **Immediate Fixes**: Add `lang="en"` to `header.html.haml` and critical skipped links.
2.  **Audit Images**: Review all `image_tag` usages and add appropriate `alt` text.
3.  **Fix Forms**: Ensure every input has a programmatic label.
4.  **Refactor Navigation**: Update navbar links to use valid ARIA labels.
5.  **Canvas Fallback**: Implement accessible alternatives for the percentage bars.
