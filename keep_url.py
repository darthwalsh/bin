"""Used to find unused URLs in Google Keep notes.

See https://github.com/obsidianmd/obsidian-importer/blob/master/src/formats/keep/models.ts#L21 for the data model"""

import glob
import json
import os
import sys


def find_unused_url(note):
    if note.get("isArchived", False):
        return

    text = note.get("textContent", "")
    for content in note.get("listContent", []):
        list_text = content.get("textContent")
        if list_text is None:
            list_text = content.get("textHtml")
        text += list_text
      
    text = normalize(text)
    
    for annot in note.get("annotations", []):
        if "url" in annot:
            url = normalize(annot["url"])
            if url not in text:
                return url


def normalize(urls: str):
    """Bunch of hacky edits to text to fix urls inside text"""
    urls = urls.replace("https://youtu.be/", "https://www.youtube.com/watch?v=")
    urls = urls.replace("https://www.", "https://")
    urls = urls.replace("http://", "https://")
    urls = urls.replace("%2F", "/")
    urls = urls.replace("%3A", ":")
    urls = urls.rstrip('/')
    urls = urls.casefold()
    return urls


def main():
    files = glob.glob(os.path.join(keep_dir, '*.json'))
    print(f"Searching {len(files)} JSON files")
    for json_file in files:
        with open(json_file, 'r') as f:
            data = json.load(f)

            try:
                url = find_unused_url(data)
                if url and 'migrated_from_assistant' not in url:
                    print(os.path.basename(json_file), url)
            except Exception as e:
                print(f"Error in {json_file}: {e}")
                raise


if __name__ == '__main__':
    keep_dir = sys.argv[1]
    main()
