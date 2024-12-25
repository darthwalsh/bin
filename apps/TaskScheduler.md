- [ ] Merge from OneNote
## Primer
https://stackoverflow.com/a/70793765/771768 has really good descriptions

## Security > Run 
- Run only when user is logged on
- Run whether user is logged in or not
From [[#Primer]]
>As you might be able to guess, `Interactive` means the task will be run under the context of a logged-on user. This can be useful when the task needs to start a GUI application, or the task action is Message Box to display a dialog on the system. Obviously, this is not useful in our case. There's also the `InteractiveOrPassword` type which combines this logon type, with the one we want, `Password`. And so I won't discuss it further.

>And now, of course, the `Password` logon type, which is the one we want. This says that a password will be stored with the scheduled task, which will be used to logon the user (as a batch job) so the task can run whether the user is logged on or not. Yes, _this_ is the value that results in setting the _Run whether the user is logged on or not_ checkbox in the Task Scheduler UI.

and
>A task that runs under a user that is not logged on will always run with the elevated token.

## Docs links
[Security Contexts for Tasks](https://learn.microsoft.com/en-us/windows/win32/taskschd/security-contexts-for-running-tasks) seems how `RunLevel` (`LUA` vs `Highest`) works. Seems like it should explain "Password means elevated" but it doesn't...
[TASK_LOGON_TYPE](https://learn.microsoft.com/en-us/windows/win32/api/taskschd/ne-taskschd-task_logon_type) Lists Password vs Interactive, but doesn't explain "Password means elevated"
[Principal.LogonType](https://learn.microsoft.com/en-us/windows/win32/taskschd/principal-logontype) ditto
[IPrincipal::get_LogonType](https://learn.microsoft.com/en-us/windows/win32/api/taskschd/nf-taskschd-iprincipal-get_logontype) has some context about message boxes and battery saver
[LogonType (principalType) Element](https://learn.microsoft.com/en-us/windows/win32/taskschd/taskschedulerschema-logontype-principaltype-element) docs on XML element, ditto message box
