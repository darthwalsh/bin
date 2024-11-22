I have been using github and OneDrive for computer document backup, but real backup tools are more comprehensive than that.

- [ ] check on my work slack what our backup strategy is ⏫ 
- [ ] Get some basic remote backup
- [ ] Automate running it weekly

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
