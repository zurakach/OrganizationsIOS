# OrganizationsIOS

This application uses GitHub REST API to load list of organizations.

Features:
- Load list of organizations
- Pagination
- Open organization page in browser


# Architecture

Using MVC architecture with adhering closely to SOLID principles.

Although MVC is regarded to be inferior architecture by some, 
there are others who think MVC is a good architecture if done correctly. 
I tend to think that MVC has it's pros and cons and should be considered a viable approach. 
I would like to mention that I also like Clean Swift (VIP) and VIPER architectures.

Pros:
- Easy onboarding
- Integrates well with UIKit
Cons:
- Easy to write code that violates SOLID principles

# Code

Setup:
When app launches, it initializes appropriate dependencies (DependencyContainer and Router). 
SceneDelegate then asks Router to provide initialViewController.

Router:
Router is responsible for handling transitions between ViewControllers 
and handling events like showing an alert.
Router is a great pattern to use. This allows us to decouple different ViewControllers from each other. 
VC doesn't need to know in what context it is displayed. VC should only care about managing their own content.


Dependencies:

Using ServiceLocator pattern as a dependency injection for this app.
I especially like ServiceLocator for following benefits:
Unlike on-demand approach, we avoid creating huge graph of dependencies. 
Object can interact with serviceLocator and get any dependencies they need.
We can have short-lived and long-leaved dependencies by having Factory methods. 
This is good since we don't have to instantiate all dependencies in advance.
I've seen many ways that others implement a process of locating a service, 
using Property wrappers or protocol extensions. 
I tend to not like those approaches since effectively they use singleton pattern. 
I prefer to explicitly inject the dependencies. Using DependencyContainer allows me to do exactly that.



Repository:
Repositories are good way to separate Data Layer from Presentation Layer. 
Presentation Layer doesn't need to know what is happening under the hood (loading data from remote api, or disk or cache, or just returning fake data). 
Another great way to decouple code.

Currently there is only one repository (OrganizationRepository). Again this is a protocol so we can inject different implementations of it based on environment. 
OrgOrganizationRepository is a production implementation. I'm using 'Org" prefix for implementations that are intended for production use.

Pagination:
To handle pagination I use iterator pattern. OrganizationListPage is an iterator that allows to load next page without exposing inner workings of how pagination is handled.
No changes will be required in Presentation layer If pagination changes from cursor based pagination to page based or any other one.

RemoteAPI
RemoteAPIs are used by Repositories to load data. Here again I use Protocol Oriented Programming to be able to set appropriate objects based on environment. 


# Presentation Layer

To avoid common pitfall of MassiveViewController in MVC I strive to write minimum code in VCs.

This can be done in two ways:
- First one is to introduce containerViewController that would mange it's view and data. In this application,
I could have introduced OrganizationsListTableViewController that would handle just a tableView.

- Second approach is to introduce ModelControllers (e.g OrganizationsListController) that handle specific part of the VC. 


For some ModelControllers could seem odd. Why not just have ContainerViewControllers instead?! That's a fair point. 
I make this distinction to have more fine grain control, Not every container in hierarchy should and could be a containerViewController. 
For example in cases where there are more complex cells, I would introduce OrganizationListCellController. 
I think making this a ViewController subclass would be overkill.


Handling TableView data is done by OrganizationsListController. 
VC is only responsible for correctly placing tableView in view hierarchy and setting setting up Presenters with appropriate dependencies.
- I think this is the most important part of making MVC great again :)
- This allows us to move some code out of the VC
- Also benefits us with being able to test tableView data handling separately


# Testing:

TBD

------

Notes:

Although pagination is implemented and works fine, I have not spend much time handling edge cases of handling errors or cancelations of page loading.
