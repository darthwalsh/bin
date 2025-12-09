I have been using github and OneDrive for computer document backup, but real backup tools are more comprehensive than that.

- [x] check what my work OneDrive backup strategy is #macbook ⏫ ⏳ 2025-01-03
	- See that [OneDrive can restore](https://support.microsoft.com/en-us/office/restore-your-onedrive-fa231298-759d-41cf-bcd0-25ac53eb8a15) up to last 30 days:  https://onedrive.live.com/?v=restore
- [ ] Consider what other backup I need
	- [ ] See other types of media: https://github.com/geerlingguy/my-backup-plan
- [ ] Get some basic remote backup
- [x] Automate running it weekly

## 3-2-1 Backup Rule
Explained in a lot of places; here's a [blog from Backblaze](https://www.backblaze.com/blog/the-3-2-1-backup-strategy).

Having a backup on-site seems less critical than focusing on better off-side backup.
## Borg
At first, was thinking it might work to just rsync a folder, then add,commit,push to a private github repo

Reading about [Borg Deduplicating Archiver](https://borgbackup.readthedocs.io/en/stable/quickstart.html) it seems to have some nice functions:
- Multiple archives: "Use the `prune` subcommand to maintain 7 daily, 4 weekly and 6 monthly"
- Deduplication of backup archive
- Backup compression
- passphrase for encrypted backup

Writing to Google Drive / OneDrive will be risky with concurrent writes
- Might be OK, if only 1 writer
- Run `borg check` on the repo regularly
- ELSE, use free account at https://www.borgbase.com/

- [-] Creating `.plist` cron https://chatgpt.com/share/68c4abd6-1458-8011-96be-d55ba284a791 ❌ 2025-12-05
	- [x] Decided to go with Vorta instead
## Vorta is GUI for Borg
[Vorta for BorgBackup](https://vorta.borgbase.com/)
- runs backup on schedule, with automatic prune
- autostart on login, use menu item instead of desktop window
More info: [How to back up data usiong Borg and Vorta - YouTube](https://www.youtube.com/watch?v=asZX2YbTaNE)
### macOS 15 FUSE mounting requires kernel extension
> To enable system extensions, you need to modify your security settings in the Recovery environment.
> To do this, shut down your system. Then press and hold the Touch ID or power button to launch Startup Security Utility.
> In Startup Security Utility, enable kernel extensions from the Security Policy button.

But according to https://macfuse.github.io/:
> ### macFUSE is evolving beyond kernel extensions
> 
> Thanks to the new FSKit backend in macFUSE, supported file systems can now run entirely in user space on macOS 26. That means no more rebooting into recovery mode to enable support for the macFUSE kernel extension. Installation is faster and setup becomes a seamless experience.

- [ ] After upgrading to macOS 26, try mounting to `~./borg_mount/`. ⏳ 2025-12-15 
