# PicFont

PicFont is the application to display Goole Fonts. Reference: `https://developers.google.com/fonts/docs/developer_api`

## System Requirements

This project develop with XCode 14.0, Swift 5.6.1. deployment target is iOS 16.0.

--

## System Architecture

PicFont develop based on VIP architecture, and separator business logic via BLoC Pattern for achieving testability and reusability.
In the data acquisition part, Google Font information will be obtained through `Session`.

### Coordinator

- AppCoordinator

Used to run initial page with UINavigationController

## GoogleFontViewController

This ViewController is the main page of the app, include:
- UITableView, showing Font and Subsets 
- UIStackView + UIScrollView, showing contents of family and subset
- UILable, for previewing UIFont

System Architecture Diagram
![CleanShot 2022-09-26 at 23 15 57](https://user-images.githubusercontent.com/8021888/192314902-94f514b4-d9d8-4f96-8f75-7735555d4cf0.png)


## Used Tech
- Combine
- `CTFontManagerRegisterGraphicsFont`
- Swift Package Manager
