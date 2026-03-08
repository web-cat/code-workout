# CodeWorkout Accessibility Conformance Report WCAG Edition
(Based on VPAT® Version 2.5rev)

**Name of Product/Version**: CodeWorkout
**Report Date**: 25 February 2026
**Product Description**: CodeWorkout is a web-based platform built with Ruby on Rails, designed to help users learn programming. It provides a space for users to practice coding exercises and multiple-choice questions, receiving immediate feedback. The platform supports both self-paced learning and structured courses for instructors.
**Contact information**: Bob Edmison (bedmison@vt.edu) Stephen H. Edwards (edwards@cs.vt.edu)
**Notes**: The source code for the application ia available on github at https://github.com/web-cat/code-workout
**Evaluation Methods Used**: Automated evaluation of the code base and both manual and automated reporting on the user-facing experience

## Applicable Standards/Guidelines

This report covers the degree of conformance for the following accessibility standard/guidelines:

<table cellspacing="0" cellpadding="0">
    <tbody>
        <tr>
            <td><strong>Standard/Guideline</strong></td>
            <td nowrap><strong>Included In Report</strong></td>
        </tr>
        <tr>
            <td><a href="http://www.w3.org/TR/2008/REC-WCAG20-20081211/">Web Content Accessibility Guidelines 2.0</a></td>
            <td nowrap>Level A &nbsp; – &nbsp; <strong>Yes</strong><br>Level AA &nbsp; – &nbsp; <strong>Yes</strong><br>Level AAA &nbsp; – &nbsp; <strong>No</strong></td>
        </tr>
        <tr>
            <td><a href="https://www.w3.org/TR/WCAG21">Web Content Accessibility Guidelines 2.1</a></td>
            <td nowrap>Level A &nbsp; – &nbsp; <strong>Yes</strong><br>Level AA &nbsp; – &nbsp; <strong>Yes</strong><br>Level AAA &nbsp; – &nbsp; <strong>No</strong></td>
        </tr>
        <tr>
            <td><a href="https://www.w3.org/TR/WCAG22/">Web Content Accessibility Guidelines 2.2</a></td>
            <td nowrap>Level A &nbsp; – &nbsp; <strong>No</strong><br>Level AA &nbsp; – &nbsp; <strong>No</strong><br>Level AAA &nbsp; – &nbsp; <strong>No</strong></td>
        </tr>
    </tbody>
</table>

## Terms

The terms used in the Conformance Level information are defined as follows:

- **Supports**: The functionality of the product has at least one method that meets the criterion without known defects or meets with equivalent facilitation.
- **Partially Supports**: Some functionality of the product does not meet the criterion.
- **Does Not Support**: The majority of product functionality does not meet the criterion.
- **Not Applicable**: The criterion is not relevant to the product.
- **Not Evaluated**: The product has not been evaluated against the criterion. This can be used only in WCAG Level AAA.

## WCAG 2.x Report

### Table 1: Success Criteria, Level A

<table>
    <thead>
        <tr>
            <th>**Criteria**</th>
            <th>**Conformance Level **</th>
            <th>**Remarks and Explanations**</th>
        </tr>
    </thead>
    <tbody>
        <tr id="non-text-content" valign="top">
            <td><a href="http://www.w3.org/TR/WCAG20/#text-equiv-all">**1.1.1 Non-text Content**</a> (Level A)</td>
            <td>Supports</td>
            <td>&nbsp;</td>
        </tr>
        <tr id="audio-only-and-video-only-prerecorded" valign="top">
            <td><a href="http://www.w3.org/TR/WCAG20/#media-equiv-av-only-alt">**1.2.1 Audio-only and Video-only (Prerecorded)**</a> (Level A)</td>
            <td>Not Applicable</td>
            <td>The application does not contain audio-only or video-only content.</td>
        </tr>
        <tr id="captions-prerecorded" valign="top">
            <td><a href="http://www.w3.org/TR/WCAG20/#media-equiv-captions">**1.2.2 Captions (Prerecorded)**</a> (Level A)</td>
            <td>Not Applicable</td>
            <td>The application does not contain video with audio.</td>
        </tr>
        <tr id="audio-description-or-media-alternative-prerecorded" valign="top">
            <td><a href="http://www.w3.org/TR/WCAG20/#media-equiv-audio-desc">**1.2.3 Audio Description or Media Alternative (Prerecorded)**</a> (Level A)</td>
            <td>Not Applicable</td>
            <td>The application does not contain video with audio.</td>
        </tr>
        <tr id="info-and-relationships" valign="top">
            <td><a href="http://www.w3.org/TR/WCAG20/#content-structure-separation-programmatic">**1.3.1 Info and Relationships**</a> (Level A)</td>
            <td>Supports</td>
            <td>&nbsp;</td>
        </tr>
        <tr id="meaningful-sequence" valign="top">
            <td><a href="http://www.w3.org/TR/WCAG20/#content-structure-separation-sequence">**1.3.2 Meaningful Sequence**</a> (Level A)</td>
            <td>Supports</td>
            <td>&nbsp;</td>
        </tr>
        <tr id="sensory-characteristics" valign="top">
            <td>**<a href="http://www.w3.org/TR/WCAG20/#content-structure-separation-understanding">1.3.3 Sensory Characteristics</a>** (Level A)</td>
            <td>Supports</td>
            <td>&nbsp;</td>
        </tr>
        <tr id="use-of-color" valign="top">
            <td><a href="http://www.w3.org/TR/WCAG20/#visual-audio-contrast-without-color">**1.4.1 Use of Color**</a> (Level A)</td>
            <td>Supports</td>
            <td>&nbsp;</td>
        </tr>
        <tr id="audio-control" valign="top">
            <td><a href="http://www.w3.org/TR/WCAG20/#visual-audio-contrast-dis-audio">**1.4.2 Audio Control**</a> (Level A)</td>
            <td>Not Applicable</td>
            <td>The application does not have audio that plays automatically.</td>
        </tr>
        <tr id="keyboard" valign="top">
            <td><a href="http://www.w3.org/TR/WCAG20/#keyboard-operation-keyboard-operable">**2.1.1 Keyboard**</a> (Level A)</td>
            <td>Supports</td>
            <td>&nbsp;</td>
        </tr>
        <tr id="no-keyboard-trap" valign="top">
            <td><a href="http://www.w3.org/TR/WCAG20/#keyboard-operation-trapping">**2.1.2 No Keyboard Trap**</a> (Level A)</td>
            <td>Supports</td>
            <td>&nbsp;</td>
        </tr>
        <tr id="character-key-shortcuts" valign="top">
            <td><a href="https://www.w3.org/TR/WCAG21/#character-key-shortcuts">**2.1.4 Character Key Shortcuts**</a> (Level A 2.1 and 2.2)</td>
            <td>Not Evaluated</td>
            <td>The audit did not test for character key shortcuts.</td>
        </tr>
        <tr id="timing-adjustable" valign="top">
            <td><a href="http://www.w3.org/TR/WCAG20/#time-limits-required-behaviors">**2.2.1 Timing Adjustable**</a> (Level A 2.1 only)</td>
            <td>Not Applicable</td>
            <td>The application has no time limits.</td>
        </tr>
        <tr id="pause-stop-hide" valign="top">
            <td><a href="http://www.w3.org/TR/WCAG20/#time-limits-pause">**2.2.2 Pause, Stop, Hide**</a> (Level A)</td>
            <td>Not Applicable</td>
            <td>The application does not have moving, blinking, or scrolling content.</td>
        </tr>
        <tr id="three-flashes-or-below-threshold" valign="top">
            <td><a href="http://www.w3.org/TR/WCAG20/#seizure-does-not-violate">**2.3.1 Three Flashes or Below Threshold**</a> (Level A)</td>
            <td>Supports</td>
            <td>No content that flashes.</td>
        </tr>
        <tr id="bypass-blocks" valign="top">
            <td><a href="http://www.w3.org/TR/WCAG20/#navigation-mechanisms-skip">**2.4.1 Bypass Blocks**</a> (Level A)</td>
            <td>Supports</td>
            <td>&nbsp;</td>
        </tr>
        <tr id="page-titled" valign="top">
            <td><a href="http://www.w3.org/TR/WCAG20/#navigation-mechanisms-title">**2.4.2 Page Titled**</a> (Level A)</td>
            <td>Supports</td>
            <td>&nbsp;</td>
        </tr>
        <tr id="focus-order" valign="top">
            <td><a href="http://www.w3.org/TR/WCAG20/#navigation-mechanisms-focus-order">**2.4.3 Focus Order**</a> (Level A)</td>
            <td>Supports</td>
            <td>&nbsp;</td>
        </tr>
        <tr id="link-purpose-in-context" valign="top">
            <td><a href="http://www.w3.org/TR/WCAG20/#navigation-mechanisms-refs">**2.4.4 Link Purpose (In Context)**</a> (Level A)</td>
            <td>Supports</td>
            <td>&nbsp;</td>
        </tr>
        <tr id="pointer-gestures" valign="top">
            <td><a href="https://www.w3.org/TR/WCAG21/#pointer-gestures">**2.5.1 Pointer Gestures**</a> (Level A 2.1 and 2.2)</td>
            <td>Not Applicable</td>
            <td>The application does not use path-based gestures.</td>
        </tr>
        <tr id="pointer-cancellation" valign="top">
            <td><a href="https://www.w3.org/TR/WCAG21/#pointer-gestures">**2.5.2 Pointer Cancellation**</a> (Level A 2.1 and 2.2)</td>
            <td>Not Applicable</td>
            <td>The application does not use path-based gestures.</td>
        </tr>
        <tr id="label-in-name" valign="top">
            <td><a href="https://www.w3.org/TR/WCAG21/#label-in-name">**2.5.3 Label in Name**</a> (Level A 2.1 and 2.2)</td>
            <td>Supports</td>
            <td>&nbsp;</td>
        </tr>
        <tr id="motion-actuation" valign="top">
            <td><a href="https://www.w3.org/TR/WCAG21/#motion-actuation">**2.5.4 Motion Actuation**</a> (Level A 2.1 and 2.2)</td>
            <td>Not Applicable</td>
            <td>The application is not motion actuated.</td>
        </tr>
        <tr id="language-of-page" valign="top">
            <td><a href="http://www.w3.org/TR/WCAG20/#meaning-doc-lang-id">**3.1.1 Language of Page**</a> (Level A)</td>
            <td>Supports</td>
            <td>&nbsp;</td>
        </tr>
        <tr id="on-focus" valign="top">
            <td><a href="http://www.w3.org/TR/WCAG20/#consistent-behavior-receive-focus">**3.2.1 On Focus**</a> (Level A)</td>
            <td>Supports</td>
            <td>&nbsp;</td>
        </tr>
        <tr id="on-input" valign="top">
            <td><a href="http://www.w3.org/TR/WCAG20/#consistent-behavior-unpredictable-change">**3.2.2 On Input**</a> (Level A)</td>
            <td>Supports</td>
            <td>&nbsp;</td>
        </tr>
        <tr id="error-identification" valign="top">
            <td><a href="http://www.w3.org/TR/WCAG20/#minimize-error-identified">**3.3.1 Error Identification**</a> (Level A)</td>
            <td>Supports</td>
            <td>&nbsp;</td>
        </tr>
        <tr id="labels-or-instructions" valign="top">
            <td><a href="http://www.w3.org/TR/WCAG20/#minimize-error-cues">**3.3.2 Labels or Instructions**</a> (Level A)</td>
            <td>Supports</td>
            <td>&nbsp;</td>
        </tr>
        <tr id="parsing" valign="top">
            <td><a href="http://www.w3.org/TR/WCAG20/#ensure-compat-parses">**4.1.1 Parsing**</a> (Level A)</td>
            <td>Supports</td>
            <td>Per WCAG 2.1 errata, this criterion is always met.</td>
        </tr>
        <tr id="name-role-value" valign="top">
            <td><a href="http://www.w3.org/TR/WCAG20/#ensure-compat-rsv">**4.1.2 Name, Role, Value**</a> (Level A)</td>
            <td>Supports</td>
            <td>&nbsp;</td>
        </tr>
    </tbody>
</table>

### Table 2: Success Criteria, Level AA

<table>
    <thead>
        <tr>
            <th>**Criteria**</th>
            <th>**Conformance Level **</th>
            <th>**Remarks and Explanations**</th>
        </tr>
    </thead>
    <tbody>
        <tr id="captions-live" valign="top">
            <td><a href="http://www.w3.org/TR/WCAG20/#media-equiv-real-time-captions">**1.2.4 Captions (Live)**</a> (Level AA)</td>
            <td>Not Applicable</td>
            <td>The application does not have live audio content.</td>
        </tr>
        <tr id="audio-description-prerecorded" valign="top">
            <td><a href="http://www.w3.org/TR/WCAG20/#media-equiv-audio-desc-only">**1.2.5 Audio Description (Prerecorded)**</a> (Level AA)</td>
            <td>Not Applicable</td>
            <td>The application does not have video content.</td>
        </tr>
        <tr id="orientation" valign="top">
            <td><a href="https://www.w3.org/TR/WCAG21/#orientation">**1.3.4 Orientation**</a> (Level AA 2.1 and 2.2)</td>
            <td>Not Applicable</td>
            <td>The application is a web application and orientation can be controlled by the user agent.</td>
        </tr>
        <tr id="identify-input-purpose" valign="top">
            <td><a href="https://www.w3.org/TR/WCAG21/#identify-input-purpose">**1.3.5 Identify Input Purpose**</a> (Level AA 2.1 and 2.2)</td>
            <td>Supports</td>
            <td>&nbsp;</td>
        </tr>
        <tr id="contrast-minimum" valign="top">
            <td><a href="http://www.w3.org/TR/WCAG20/#visual-audio-contrast-contrast">**1.4.3 Contrast (Minimum)**</a> (Level AA)</td>
            <td>Supports</td>
            <td>&nbsp;</td>
        </tr>
        <tr id="resize-text" valign="top">
            <td><a href="http://www.w3.org/TR/WCAG20/#visual-audio-contrast-scale">**1.4.4 Resize text**</a> (Level AA)</td>
            <td>Partially Supports</td>
            <td>The programming code window can accept larger text, but the size of the text impacts the amount of text in the window, and thus the scrolling required to view the text.</td>
        </tr>
        <tr id="images-of-text" valign="top">
            <td><a href="http://www.w3.org/TR/WCAG20/#visual-audio-contrast-text-presentation">**1.4.5 Images of Text**</a> (Level AA)</td>
            <td>Supports</td>
            <td>&nbsp;</td>
        </tr>
        <tr id="reflow" valign="top">
            <td><a href="https://www.w3.org/TR/WCAG21/#reflow">**1.4.10 Reflow**</a> (Level AA 2.1 and 2.2)</td>
            <td>Partially Supports</td>
            <td>The application will reflow, but the code window will always maintain a minimum width/height.</td>
        </tr>
        <tr id="non-text-contrast" valign="top">
            <td><a href="https://www.w3.org/TR/WCAG21/#non-text-contrast">**1.4.11 Non-text Contrast**</a> (Level AA 2.1 and 2.2)</td>
            <td>Supports</td>
            <td>&nbsp;</td>
        </tr>
        <tr id="text-spacing" valign="top">
            <td><a href="https://www.w3.org/TR/WCAG21/#text-spacing">**1.4.12 Text Spacing**</a> (Level AA 2.1 and 2.2)</td>
            <td>Supports</td>
            <td>&nbsp;</td>
        </tr>
        <tr id="content-on-hover-or-focus" valign="top">
            <td><a href="https://www.w3.org/TR/WCAG21/#content-on-hover-or-focus">**1.4.13 Content on Hover or Focus**</a> (Level AA 2.1 and 2.2)</td>
            <td>Not applicable</td>
            <td>The application does not implement any user interface elements in this manner.</td>
        </tr>
        <tr id="multiple-ways" valign="top">
            <td><a href="http://www.w3.org/TR/WCAG20/#navigation-mechanisms-mult-loc">**2.4.5 Multiple Ways**</a> (Level AA)</td>
            <td>Not applicable</td>
            <td>The application is a true application, so all pages are dynamically created based on user interactions.</td>
        </tr>
        <tr id="headings-and-labels" valign="top">
            <td><a href="http://www.w3.org/TR/WCAG20/#navigation-mechanisms-descriptive">**2.4.6 Headings and Labels**</a> (Level AA)</td>
            <td>Supports</td>
            <td>&nbsp;</td>
        </tr>
        <tr id="focus-visible" valign="top">
            <td><a href="http://www.w3.org/TR/WCAG20/#navigation-mechanisms-focus-visible">**2.4.7 Focus Visible**</a> (Level AA)</td>
            <td>Supports</td>
            <td>&nbsp;</td>
        </tr>
        <tr id="language-of-parts" valign="top">
            <td><a href="http://www.w3.org/TR/WCAG20/#meaning-other-lang-id">**3.1.2 Language of Parts**</a> (Level AA)</td>
            <td>Supports</td>
            <td>&nbsp;</td>
        </tr>
        <tr id="consistent-navigation" valign="top">
            <td><a href="http://www.w3.org/TR/WCAG20/#consistent-behavior-consistent-locations">**3.2.3 Consistent Navigation**</a> (Level AA)</td>
            <td>Supports</td>
            <td>&nbsp;</td>
        </tr>
        <tr id="consistent-identification" valign="top">
            <td><a href="http://www.w3.org/TR/WCAG20/#consistent-behavior-consistent-functionality">**3.2.4 Consistent Identification**</a> (Level AA)</td>
            <td>Supports</td>
            <td>&nbsp;</td>
        </tr>
        <tr id="error-suggestion" valign="top">
            <td><a href="http://www.w3.org/TR/WCAG20/#minimize-error-suggestions">**3.3.3 Error Suggestion**</a> (Level AA)</td>
            <td>Supports</td>
            <td>&nbsp;</td>
        </tr>
        <tr id="error-prevention-legal-financial-data" valign="top">
            <td><a href="http://www.w3.org/TR/WCAG20/#minimize-error-reversible">**3.3.4 Error Prevention (Legal, Financial, Data)**</a> (Level AA)</td>
            <td>Not applicable</td>
            <td>The application does not implement any features involving legal or financial data.</td>
        </tr>
        <tr id="status-messages" valign="top">
            <td><a href="https://www.w3.org/TR/WCAG21/#status-messages">**4.1.3 Status Messages**</a> (Level AA 2.1 and 2.2)</td>
            <td>Not applicable</td>
            <td>The application does not implement status messages.</td>
        </tr>
    </tbody>
</table>

### Table 3: Success Criteria, Level AAA

Notes: This product has not been evaluated for WCAG 2.x Level AAA conformance.


## Legal Disclaimer

We have made a good faith effort to accurately describe the application at the time of this evaluation. However, the application is in active development and it is possible that regressions may be introduced into the system that may impact conformance to the WCAG 2.1 Level AA standard. 

This document is provided for informational purposes only and the contents hereof are subject to change without notice. This document is not a warranty of any kind, either expressed or implied.
