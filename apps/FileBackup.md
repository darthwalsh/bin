---
aliases:
  - borg
  - vorta
---
I have been using github and OneDrive for computer document backup, but real backup tools are more comprehensive than that.

- [x] check what my work OneDrive backup strategy is #macbook ⏫ ⏳ 2025-01-03
	- See that [OneDrive can restore](https://support.microsoft.com/en-us/office/restore-your-onedrive-fa231298-759d-41cf-bcd0-25ac53eb8a15) up to last 30 days:  https://onedrive.live.com/?v=restore
- [ ] Consider what other backup I need
	- [ ] See other types of media: https://github.com/geerlingguy/my-backup-plan
- [ ] Get some basic remote backup
- [x] Automate running it weekly

## 3-2-1 Backup Rule
Having a backup on-site seems less critical than focusing on better off-side backup.

Explained in a lot of places; here's a [blog from Backblaze](https://www.backblaze.com/blog/the-3-2-1-backup-strategy).
Read [geerlingguy/my-backup-plan](https://github.com/geerlingguy/my-backup-plan) and/or Watch [Backups: You're doing 'em wrong!](https://www.youtube.com/watch?v=S0KZ5iXTkzg)

> 3 Copies of all my data
> 2 Copies on different storage media
> 1 Offsite copy

- [ ] [[GooglePhotos]]
- [ ] Files in [[OneDrive]]
	- [x] Current high-touch files in `MyNotes` is backed up
- [x] Music -> OneDrive
- [ ] OSS -> [[GitHub]]
## Borg
At first, was thinking it might work to just [[rsync]] a folder, or git `push` to a private github repo.

Reading about [Borg Deduplicating Archiver](https://borgbackup.readthedocs.io/en/stable/quickstart.html) it seems to have some nice functionality:
- Multiple archives: "Use the `prune` subcommand to maintain 7 daily, 4 weekly and 6 monthly"
- Deduplication of backup archive
- Backup compression
- passphrase for encrypted backup
- [Containers | BorgBase Docs](https://docs.borgbase.com/setup/borg/containers#step-2---backup-volumes) for backing up [[docker]] volumes

My plan:
- [-] Automate cron with `.plist` [[launchd]] or [[pitchfork]] ❌ 2025-12-05
- [x] Decided to go with Vorta instead
- [ ] If Vorta doesn't work out, could use [Borgmatic](https://docs.borgbase.com/setup/borg/cli#step-6--set-up-borgmatic-for-regular-backups) to handle multiple repos but still need cron
### cat old file
```
export BORG_REPO=ssh... 
  export BORG_PASSPHRASE=...
borg list --sort-by timestamp | fzf
export ARCHIVE=the-machine-2025-11-26-161734

borg list "$BORG_REPO::$ARCHIVE" | fzf
export FILE=the/file

borg extract --stdout "$BORG_REPO::$ARCHIVE" $FILE | less
```
- [ ] fzf script? or something like bisect? Maybe scoped to subheading?
## Vorta Is GUI for Borg
[Vorta for BorgBackup](https://vorta.borgbase.com/)
- Runs back up on schedule, with automatic prune
- Auto-start on login, use menu item instead of desktop window
More info: [How to back up data usiong Borg and Vorta - YouTube](https://www.youtube.com/watch?v=asZX2YbTaNE)
- [x] Disable "Check for Full Disk Access on startup" because the app doesn't actually request that permission on my machine...
- Requires Borg 1.x — BorgBase runs 1.4.x. Verify: `borg --version` (if you installed 2.x, `brew install borgbackup` gives 1.x)
### macOS 15 FUSE mounting requires kernel extension
> To enable system extensions, you need to modify your security settings in the Recovery environment.
> To do this, shut down your system. Then press and hold the Touch ID or power button to launch Startup Security Utility.
> In Startup Security Utility, enable kernel extensions from the Security Policy button.

But according to https://macfuse.github.io/:
> ### macFUSE is evolving beyond kernel extensions
> 
> Thanks to the new FSKit backend in macFUSE, supported file systems can now run entirely in user space on macOS 26. That means no more rebooting into recovery mode to enable support for the macFUSE kernel extension. Installation is faster and setup becomes a seamless experience.

- [ ] Requires macOS 26, try mounting to `~./borg_mount/`.
	- [x] Upgraded to 26.5

## Compare to similar tools:
- [Compare](https://docs.borgbase.com/setup/#step-1---choosing-a-backup-tool) to newer backup tools supported by BorgBase, which are multi-threaded and single-binary: Restic or Vykar (includes scheduler)
- [Pika Backup](https://docs.borgbase.com/setup/borg/pika) is a linux borg GUI

## Runbooks

### My Vorta config

- Profile
	- name **SSH**
	- repo: `ssh://ABCXYZ@ABCXYZ.repo.borgbase.com/./repo`
	- encryption: see [[#pw1 Vorta Borg encryption passphrase|1pw]]
- Sources
	- add these folder: `~/Library/CloudStorage/OneDrive-Personal/.../MyNotes` and anything else relevant
- Schedule
	- Schedule mode: `interval`, every `1 hour`
	- Compaction: on, every `3 weeks`
	- Prune after each backup: `ON`
	- Archives tab > Prune Options
		- Hourly: 24
		- Daily: 8
		- Weekly: 5
		- Monthly: 12
		- Yearly: 99
		- Keep within: _(empty)_

### rsync a borg repo
> [!NOTE] If the repo lives in OneDrive, rsync it out first — Files On-Demand may not have all chunks locally, causing read errors mid-copy.
```
rsync -aP /path/to/your/OneDrive/repo ~/tmp/borg-import/BorgRepo/
  export BORG_PASSPHRASE=<BLAH>
export BORG_REPO=~/tmp/borg-import/BorgRepo/
borg info
borg check
```
### Using OneDrive is risky but works
>[!WARNING] Only have 1 machine writing, ever!

Writing to Google Drive / OneDrive will be risky with concurrent writes!
1. Finder > Right Click > Always keep on Device
2. [x] Run `borg check "$HOME/Library/CloudStorage/OneDrive-Personal/path/to/borg"`

### Writing to BorgBase over SSH
Account: [Add SSH public key](https://www.borgbase.com/ssh)
Add [TOTP 2FA](https://www.borgbase.com/account?tab=profile) 

1. https://www.borgbase.com/repositories
2. Basics: Region US
3. Access: your SSH key
	1. test this later: `ssh -T ABCXYZ@ABCXYZ.repo.borgbase.com -vv`
4. Monitoring: 14 days
5. Advanced: SFTP enable. Storage limit 8GB (safety margin vs. 10GB free plan)
6. Export existing repo [(docs)](https://docs.borgbase.com/setup/import): only copy into a **new empty** repo:
    ```bash
    # Might use: caffeinate -dims &  # keeps Mac awake during upload
    $ cd /your/existing/borg/repo
    $ $id = 'ABCXYZ'
    $ sftp $id@$id.repo.borgbase.com:repo
    sftp> put -Rp .
    ```
7. Disable SFTP so normal SSH borg protocol is enabled
8. Test it worked, even though borg is paranoid about seeing the same repo at a new location:
    ```bash
    $ cd /
    $ export "BORG_REPO=ssh://$id@$id.repo.borgbase.com/./repo"
    $ borg info
    Warning: The repository at location ssh://... was previously located at /you/...
    Do you want to continue? [yN] y
    ...
    ```
9. In Vorta: add SSH repo, Start Backup, verify Archives
