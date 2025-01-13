![Citykey App's Overview](./images/cover.png)

[![OpenSSF Scorecard Score](https://api.scorecard.dev/projects/github.com/telekom/citykey-ios/badge)](https://scorecard.dev/viewer/?uri=github.com/telekom/citykey-ios/badge)

# Citykey App (iOS Client)

## Overview

Citykey is an urban living companion developed by [Deutsche Telekom AG](https://www.telekom.com/de),
designed to enhance the experience of residents and visitors in German cities. The app provides easy
access to local services, events, and transportation information, making it a must-have tool for
navigating urban environments. It is the digital way to access the citizen services.

Please [visit the website](https://citykey.app) for more information!

## Features

- **Garbage collection calendar:🚛**:
    - Distinguish between different types of garbage, such as residual waste, waste paper and
      organic waste
    - Always up-to-date and street-accurate
    - The smart garbage collection calendar helps you plan weeks in advance
- **Find events / activities:🎭**:
  Always stay in the loop about interesting events in your city!
    - Find festivals, events and cultural activities in your area
    - Use built-in filters for your interests
    - Citykey shows you an overview of upcoming events
    - Share exciting events with your friends over Citykey
    - Add activities and events to your calendar
- **News:🛰**:
    - Keep track of the latest city-related news
    - Get daily updates about important topics, such as culture, community, citizens, nature and
      helpful news
- **Book appointments with offices:👨‍💼**:
    - Book appointments with your local office and minimize waiting times when dealing with
      authorities
    - Ensure you have all documents required for your appointment and get the location to easily
      find the office
- **Digital administration with your eID:📱**:
    - Fill out forms for various administrative purposes
    - Citykey supports the Online ID (eID) of the ID card for identification on the Internet, so you
      can use even more citizen services digitally and mobile-friendly. The electronic residence
      permit is also supported
    - Take care of common applications in no time at all, such as applying for a resident parking
      permit or changing your residency
- **Citizen participation:📝**:
  Shaping the city together is now made even easier.
    - Take part in surveys on urban development and all projects that affect you
    - View all ongoing surveys in an overview
- **Interesting places:🌃**:
  New to your city? Get the best tips and first-hand information.
    - Find out what characterizes the city and which places are worth a visit
    - The app helps you find your way around and get familiar with the city faster
- **Defect reporter:🤳🚧**:
  A deep pothole in the road, a crooked guard rail or a defective street light caught your eye?
    - Report damaged or defective infrastructure to the city
    - Detail your request, simply by sending a photo with a location marker

## Want to try out?

App Store deployed: https://apps.apple.com/ua/app/citykey-citizen-services/id1516529784

## Building From Source

The first step is to clone the source code repository.

    $ git clone https://gitlab.devops.telekom.de/osca/osca_develop/osca-ios-core

Then, rename a file `OSCA-Secrets.template.plist` file to `OSCA-Secrets.plist` in the root folder, and then feed the required keys to the above said plist. For more details Please [contact us](https://public.telekom.de/digitalisierungsloesungen/smart-city#Kontaktaufnahme)

Use `OSCA Int` scheme variant to run the application for debugging purpose.

## Contribute

Code contributions are welcome!

You should fork the repo as described
here: https://docs.gitlab.com/ee/user/project/repository/forking_workflow.html

See the Issues list for bug
reports: https://gitlab.devops.telekom.de/osca/osca_develop/osca-ios-core/-/issues

Before adding new features, please create an issue, or contact
us: https://public.telekom.de/digitalisierungsloesungen/smart-city#Kontaktaufnahme

See the [CONTRIBUTING](./CONTRIBUTING.md) file for more details.

## License

See the [LICENSE](./LICENSE) file for more details.
