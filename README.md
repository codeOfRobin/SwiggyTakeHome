# Swiggy Take Home README
Hi Swiggy folks! 👋

I'm Robin, and first of all I'd like to thank you for letting me participate in your iOS engineer challenge. It's been a lot of fun and honestly I've learned a lot. I really appreciate the fact that it was a problem that Swiggy faces in the real world, and not something off-into-the-weeds theoretical.


# Goals

Our aim in this challenge was to build a flow for choosing variations in a dish, similar to something you’d see in, say a 🍕  delivery app


# Things I think I’ve done well
- State management - there’s proper well-defined loading states and single sources of truth.
- The app is architected using MVC + Coordinators - an architecture suggested by [Khanlou | Coordinators Redux](http://khanlou.com/2015/10/coordinators-redux/) . More on this in the **Coordinators** section.
- The API layer is 100% unit tested and decoupled - from building requests to ensuring my `Codable` implementations work as expected.
- Proper Localization support with all strings encoded in the `Constants.swift` file.
- Each file is < 200 lines. (No Massive View Controllers here. 😉)
- I’ve also given special thought to making the UI as “recoverable” as possible: More on this in the  `Considerations` section


## Coordinators

In MVC-C, every View Controller in the flow is managed by a high level `Coordinator` object that handles pushing, presentation, model mutation and a host of other responsibilities.

The app uses Coordinators to ensure decoupling in the View Controllers and easy testability. Since Coordinators talk to View Controllers (and coordinators talk to their children) via delegates, this architecture is inherently testable, owing to the fact that we can pass in our own objects conforming to a protocol.


## Considerations
-  recommends in the HIG that user interfaces be *recoverable.* This means that if the app is in a state that the user doesn’t want to be in (say an error, or in our case, a choice that’s not available), we must provide the user with instructions on how to get out of that state. So, if the user tries to choose a Variation that isn’t available (say, a small Cheese Burst 🍕), the app gives an obvious error alert pointing them to the previous choice that led them there.
![](https://d2mxuefqeaa7sj.cloudfront.net/s_4303F6B53268AA89D3E1EE6BA33AED940A1013EFDA715CB7CC729719A99FBBD0_1527161874348_file.png)

![](https://d2mxuefqeaa7sj.cloudfront.net/s_4303F6B53268AA89D3E1EE6BA33AED940A1013EFDA715CB7CC729719A99FBBD0_1527162277358_file.png)

- In the first load, I’ve used an embeddable child view controller approach (as suggested by John Sundell’s post [here](https://www.swiftbysundell.com/posts/using-child-view-controllers-as-plugins-in-swift)). This lets me reuse the LoadingViewController in as many places as possible in the future(for example, if you’d like to load the next set of variants from an API). In order to make the app *feel* faster, the activity indicator doesn’t appear for the first 1.5 seconds - the less time the user spends staring at a spinner, the faster the app *feels*.
- The API layer relies on a decoupled `APIRequestBuilder` that creates requests for the actual `APIClient`. Do note that the `APIClient` runs on pure `URLSession`, thus allowing for easy testability without swizzling (unlike, say Alamofire).



# Things I can improve


- The cells in the `UITableView`s could be a better - I’m using plain `UITableViewCell`s right now due to time constraints, but given more time I'd use a custom cell that could present more information - such as veg/non-veg, whether the variant is in stock etc.

