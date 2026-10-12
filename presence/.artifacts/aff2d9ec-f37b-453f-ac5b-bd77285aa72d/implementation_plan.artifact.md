# Implementation Plan: Fix Layout Overlap and Overflows

This plan addresses the issue where screen content overlaps with the AppBar and overflows the screen boundaries.

## Proposed Changes

### [Widgets]

#### [MODIFY] [app_background.dart](file:///home/time/StudioProjects/presencia/presence/lib/ui/widgets/app_background.dart)
- Add `addAppBarPadding` property (default: `true`).
- When `addAppBarPadding` is true, wrap the child in a `Padding` widget with `top: kToolbarHeight` to ensure content starts below the AppBar.
- Keep `useSafeArea` logic to handle notches.

### [Screens]

For all affected screens (Dashboard, Youth List, Sessions, Groups, Settings, Add/Edit Adolescent, Reports, Stats):
- Remove the manually added `SafeArea` widget wrapping `AppBackground`.
- Configure `AppBackground` with `useSafeArea: true` and `addAppBarPadding: true`.
- Ensure the main container for the content is scrollable (e.g., `SingleChildScrollView` or `ListView`) to prevent overflow when content exceeds screen size or the keyboard appears.

#### Screens to update:
- [dashboard_screen.dart](file:///home/time/StudioProjects/presencia/presence/lib/ui/screens/dashboard_screen.dart)
- [youth_list_screen.dart](file:///home/time/StudioProjects/presencia/presence/lib/ui/screens/youth_list_screen.dart)
- [attendance_sessions_screen.dart](file:///home/time/StudioProjects/presencia/presence/lib/ui/screens/attendance_sessions_screen.dart)
- [groups_screen.dart](file:///home/time/StudioProjects/presencia/presence/lib/ui/screens/groups_screen.dart)
- [settings_screen.dart](file:///home/time/StudioProjects/presencia/presence/lib/ui/screens/settings_screen.dart)
- [add_adolescent_screen.dart](file:///home/time/StudioProjects/presencia/presence/lib/ui/screens/add_adolescent_screen.dart)
- [attendance_report_screen.dart](file:///home/time/StudioProjects/presencia/presence/lib/ui/screens/attendance_report_screen.dart)
- [stats_screen.dart](file:///home/time/StudioProjects/presencia/presence/lib/ui/screens/stats_screen.dart)
- [session_detail_screen.dart](file:///home/time/StudioProjects/presencia/presence/lib/ui/screens/session_detail_screen.dart)
- [group_detail_screen.dart](file:///home/time/StudioProjects/presencia/presence/lib/ui/screens/group_detail_screen.dart)
- [take_attendance_screen.dart](file:///home/time/StudioProjects/presencia/presence/lib/ui/screens/take_attendance_screen.dart)

## Verification Plan

### Manual Verification
- Check every updated screen on the device.
- Verify that the title of the page (in the content) doesn't hide behind the AppBar.
- Verify that there are no "Yellow and Black" overflow stripes, especially when opening the keyboard in forms.
- Ensure the background gradient/color still extends to the very top of the screen (behind the status bar).
