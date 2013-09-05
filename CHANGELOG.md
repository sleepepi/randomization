## 0.1.0 (September 5, 2013)

### Enhancements
- **Project Changes**
  - **Permuted-block Configuration**
      - Treatment Arms can now be specified along with a weight allocation
      - Stratification Factors with options can now be specified
      - Different block sizes and allocations can now be specified
      - Randomization goal can now be specified
  - **List Generation**
      - Lists are now generated as a product of the stratification factor options
      - Randomization lists are now popuplated by shuffled blocks
      - Randomization lists are now saved once generated, and can be regenerated
      - Lists can only be regenerated if they have zero randomized subjects
  - **Subject Randomization**
      - Subjects can now be randomized to lists
      - Randomizations can be undone
      - Randomizations now keep track of the user who randomized the subject
      - Emails are sent when subjects are randomized
  - **Target Goal**
      - Projects display the overall progress towards the randomization goal
      - Randomizations now show the randomization number of the total randomization goal
      - Number of subjects per treatment arm are listed on project show page
  - **User Management**
      - Editors and Viewers can now be invited to projects

## 0.0.0 (August 21, 2013)

- Skeleton files to initialize Rails application with testing framework and continuous integration
- Users can login and be activated
- Users can create projects
