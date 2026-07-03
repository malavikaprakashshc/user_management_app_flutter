# abeltech_machine_test


## Project setup instructions
- Flutter SDK 3.11
- Dart SDK
- Android Studio or VS Code
- Android Emulator or iOS Simulator
- Fetch dependencies 'flutter pub get'


## Project Architecture
Project is developed using clean architecture.
- Data Layer contains 
    - model(data model for data coming from backend) 
    - repository implementation(which contains the implementation of the functions declared in the abstract repository class)
- Domain Layer contains 
    - entity(data object for usage in the UI) 
    - repository(abstarct class which contains the neccesary functions declared)
- Presentation Layer is divided into features 
    - user list (contains providers and views for displaying the user list and populating data according to search value and normal complete list)
    - user detail (contains providers and view for displaying the user details)
    - provider folder contains the repository provider for accessing the api functions.


## Github link
https://github.com/malavikaprakashshc/user_management_app_flutter.git

