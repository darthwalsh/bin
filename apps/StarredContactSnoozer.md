---
tags:
  - app-idea
created: 2022-11-25
---

1. [ ] Figure out API call to automate toggling starred [[#AI-Generated Gemini suggestion to change stars]]
2. [ ] Automate a cronjob schedule based on [[CalendarTriggers]]

## API to toggle Stars
App Script used to have Contacts service, but now wants you to use People API
https://developers.google.com/apps-script/advanced/people

https://developers.google.com/people/api/rest/v1/contactGroups.members/modify

Need to add user to `contactGroups/starred`

SCOPE: `https://www.googleapis.com/auth/contacts`

Exceptions to verification requirements
https://support.google.com/cloud/answer/9110914#exceptions-ver-reqtszippy2Cexceptions-to-verification-requirements
If your app is going to be used in any of the following scenarios, you do not need to submit it for review:

Personal Use: The app is not shared with anyone else or will be used by fewer than 100 users (all of whom are known personally to you). Note that your app will be subject to the unverified app screen and the 100-user cap will be in effect.


## AI-Generated Gemini suggestion to change stars
https://g.co/gemini/share/cbcea961b856

> Are there any automated tools that can update your starred contacts like you could snooze a starred contact for several days and then they would become on starred and then later after those days they would be starred

- [ ] de-halucinate this
### Potential Workarounds

While a direct "snooze" feature might not exist, here are some alternative approaches you could consider:

1. **Labeling System:**
    - Create a label or category like "Snoozed."
    - Manually apply this label to contacts you want to "snooze."
    - Set reminders or calendar events to review and remove this label after the desired period.
2. **Third-Party Apps (with Limitations):**
    - Some task management or productivity apps might allow you to create tasks associated with specific contacts.
    - You could set due dates for these tasks and use them as a reminder to temporarily "unstar" the contact.
    - However, this would require manual intervention to update both the task and the contact's starred status.
3. **Custom Scripting (Advanced):**
    - For users with technical expertise, scripting languages like Python could be used to interact with contact management APIs (if available).
    - This approach would allow for more precise automation, but it requires significant programming knowledge and might not be feasible for everyone.


### Understanding the Approach
 1. Trigger: We'll set up a trigger to run a script periodically (e.g., daily).
 2. Retrieve Starred Contacts: The script will fetch all starred contacts from your Google Contacts.
 3. Check "Snooze" Status: We'll assume there's a custom field or label called "Snooze" associated with each contact. The script will check if this field is set and, if so, if the "snooze" period has expired.
 4. Update Starred Status: If the snooze period has expired, the script will unstar the contact. If the snooze period is still active, the script will do nothing.
Creating the Google Apps Script
 1. Access Google Apps Script: Go to your Google Workspace and create a new Google Apps Script project.
 2. Write the Script: Paste the following code into your script editor:
```js
function snoozeStarredContacts() {
  var contacts = ContactsApp.getContactsByLabel('Starred');
  for (var i = 0; i < contacts.length; i++) {
    var contact = contacts[i];
    var snoozePeriod = contact.getCustomField('Snooze');
    if (snoozePeriod) {
      var snoozeEndDate = new Date(snoozePeriod);
      if (snoozeEndDate < new Date()) {
        contact.removeStar();
      }
    }
  }
}
```
 * Set a Trigger: Go to Edit > Current project's triggers. Create a new trigger, select the `snoozeStarredContacts` function, and set the desired frequency (e.g., daily).
Customization
 * Custom Field: Ensure you have a custom field named "Snooze" in your Google Contacts.
 * Snooze Period: Adjust the `snoozePeriod` logic to match your desired snooze duration. For example, to snooze for 3 days, you could store the end date in the "Snooze" field.
 * Additional Conditions: You can add more conditions to the script, such as only snoozing contacts of a specific type or label.
Note: While this script provides a basic solution, you might need to refine it based on your specific requirements and the structure of your Google Contacts.
Would you like to explore this further or do you have any other questions?

