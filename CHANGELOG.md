## 0.1.8 (May 29, 2014)

### Enhancements
- Use of Ruby 2.1.2 is now recommended
- **Gem Changes**
  - Updated to redcarpet 3.1.2

## 0.1.7 (May 8, 2014)

### Bug Fix
- Fixed minor styling issue with `Randomize!` button

## 0.1.6 (May 8, 2014)

### Enhancments
- **General Changes**
  - Slight modifications to subject randomized email notifications
- **Subject Randomization**
  - Users must now attest to the correctness of the randomization when the randomization is created
  - Subject randomized emails are now also sent to the user who entered the randomization

## 0.1.5 (May 8, 2014)

### Enhancements
- **General Changes**
  - Updated email styling template
- **Gem Changes**
  - Updated to rails 4.1.1
  - Updated to contour 2.5.0

## 0.1.4 (February 27, 2014)

### Enhancements
- Minor GUI changes and fixes for JavaScript and Turbolinks
- Use of Ruby 2.1.1 is now recommended
- **Gem Changes**
  - Updated to rails 4.0.3
  - Updated to contour 2.4.0.beta3
  - Updated to kaminari 0.15.1

## 0.1.3 (January 8, 2014)

### Enhancements
- Use of Ruby 2.1.0 is now recommended
- **Gem Changes**
  - Updated to pg 0.17.1
  - Updated to jbuilder 2.0
  - Updated to contour 2.2.1

## 0.1.2 (December 5, 2013)

### Enhancements
- Use of Ruby 2.0.0-p353 is now recommended

## 0.1.1 (December 4, 2013)

### Enhancements
- **Gem Changes**
  - Updated to rails 4.0.2
  - Updated to contour 2.2.0.rc2
  - Updated to kaminari 0.15.0
  - Updated to coffee-rails 4.0.1
  - Updated to sass-rails 4.0.1
  - Updated to simplecov 0.8.2
  - Updated to pg 0.17.0
- Turbolinks enabled
- Removed support for Ruby 1.9.3

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
