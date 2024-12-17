Viewable at https://assistant.google.com/tasks
Now also accessible at https://calendar.google.com/calendar/u/0/r/tasks

Was using Google Reminders, which is now deprecated and migrated into Google Tasks. (TBH, I think their team did a great job compared to all the others [killed by Google](https://killedbygoogle.com/).)

I'll mostly create Reminders from my phone, and move them during [[GTD#Process]].
## Subtasks are weird when sorted by date
Something weird about Google Tasks: you can assign subtasks to have their own due date.

If you create a subtask while in the "sort by date" mode, it gets the same due date as the parent task--but if you create subtask in "My order" view it does not get any due date.

Then if you switch it back to "sort by date" mode the subtask hierarchy is flattened, and you can't tell which parent a subtask belongs to. Any subtask without a due date ends up sorted to the end with the rest of the No Date items...
## Using Google Calendar to edit limits dates
From the Google tasks app, you can easily clear a task's date or time 
But using the calendar app which will also show you your tasks, it is not allow you to clear the due date...?
## Can't manually add links to tasks
i.e. in https://support.google.com/calendar/thread/187256367/google-task-external-urls?hl=en
If I create a Task and then later want to link to a web page or gmail thread, I can't?

Workaround: Create a new task with the link, then copy over the title/details/recurrance to the new task
## Can't add recurrence if removed
When removing recurrence it shows:
>Stop repeating this task
Remove all future occurrences? You won't be able to make this task repeating again.

I can't imagine what weird tech debt causes this limitation...
## Search is weak
only search is using browser text find. won't find completed entries
## API access
### Trying to use gtasks
Go project
Main project: https://github.com/BRO3886/gtasks
Fork with intention to fix Auth, eventually: https://github.com/EvanEdwards/gtasks

Somebody else [uses this in Obsidian](https://github.com/BRO3886/gtasks/issues/26#issuecomment-2103199168): see [forks](https://github.com/EvanEdwards/gtasks/network)

Installing from https://gtasks.sidv.dev/docs/installation/ got error
```
$ cd /tmp
$ go get github.com/BRO3886/gtasks
go: go.mod file not found in current directory or any parent directory.
```
- [ ] maybe PR the updated steps to the hugo webpage source? https://github.com/BRO3886/gtasks/blob/master/docs/content/docs/installation/index.md?plain=1 

- [x] Installed https://github.com/BRO3886/gtasks?tab=readme-ov-file#instructions-to-install
- apparently login needs workaround: https://github.com/BRO3886/gtasks/issues/22#issuecomment-1306019171
- login blocked on https://github.com/BRO3886/gtasks/issues/26
- there is a workaround to create new GCP client secret: https://github.com/BRO3886/gtasks/issues/19
	- but apparently OAuth Out-of-Band is deprecated, and needs migration to `http://localhost` listener

- [x] Uninstalled it

### Trying to use gtaskcli
- [x] cloned it
- [ ] Need to set up `client_secret_abc.apps.googleusercontent.com.json`
	- [ ] Follow setup in https://github.com/insanum/gcalcli?tab=readme-ov-file#initial-setup
	- [ ] links to great steps for making GCP project ⏫ 
	- [ ] OR, Try [workaround](https://github.com/BRO3886/gtasks/issues/19) from the gtasks app