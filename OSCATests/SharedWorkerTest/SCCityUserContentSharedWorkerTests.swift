//
//  SCCityUserContentSharedWorkerTests.swift
//  SmartCityTests
//
//  Created by Alexander Lichius on 17.02.20.
//  Copyright © 2020 Deutsche Telekom AG - VTI Organization. All rights reserved.
//

import XCTest
@testable import OSCA

class SCCityUserContentSharedWorkerTests: XCTestCase {
    let cityContentSharedWorker = SCCityContentSharedWorker(requestFactory: MockRequest())
    let userContentSharedWorker = SCUserContentSharedWorker(requestFactory: MockRequest())
    var cityUserContentSharedWorker: SCUserCityContentSharedWorker!
    var didChangeEventFavoritesNotification = 0
    var favoriteEventsLoadingFailedNotification = 0
    
    override func setUp() {
        cityContentSharedWorker.triggerCityContentUpdate(for: 5) { (error) in }
        userContentSharedWorker.triggerUserDataUpdate { (error) in }
        cityUserContentSharedWorker = SCUserCityContentSharedWorker(requestFactory: MockRequest(), cityIdentifier: cityContentSharedWorker, userIdentifier: userContentSharedWorker)
         NotificationCenter.default.addObserver(self, selector: #selector(reactToNotification), name: .didChangeFavoriteEventsDataState, object: nil)
        
    }

    func testFavoriteEventAppending() {
        
        // CURRENTLY NOT IMPLEMENTED ON SOL
        
        /*
        let contentTriggeredAndFetchedExpectation = expectation(description: "cityUserContentWorker stored 1 favorited Event")
        cityUserContentSharedWorker.triggerFavoriteEventsUpdate { (error) in
            if error != nil {
                print("failure")
            } else {
                XCTAssertTrue(self.cityUserContentSharedWorker.getUserCityContentData()?.favorites?.count ?? 0 > 0)
                contentTriggeredAndFetchedExpectation.fulfill()
            }
        }
        wait(for: [contentTriggeredAndFetchedExpectation], timeout: 0.5)*/
    }
    
    func testFavoriteEventRemoval() {
        
        
        let contentTriggeredAndFetchedExpectation = expectation(description: "cityUserContentWorker stored 1 favorited Event and removed it also again")
        cityUserContentSharedWorker.triggerFavoriteEventsUpdate { (error) in }
        let event = cityUserContentSharedWorker.getUserCityContentData()?.favorites?.first
        if let event = event {
            cityUserContentSharedWorker.removeFavorite(event: event)
        }
        let isFalse: Bool = self.cityUserContentSharedWorker.getUserCityContentData()?.favorites?.count ?? 0 > 0
        if !isFalse {
            contentTriggeredAndFetchedExpectation.fulfill()
        }
        
        wait(for: [contentTriggeredAndFetchedExpectation], timeout: 0.5)
    }
    
    func testFavoriteEventsIsNotLoading() {
        
        cityUserContentSharedWorker.triggerFavoriteEventsUpdate { (error) in
            XCTAssertFalse(self.cityUserContentSharedWorker.favoriteEventsDataState.dataLoadingState == .fetchingInProgress)
            XCTAssertFalse(self.cityUserContentSharedWorker.favoriteEventsDataState.dataLoadingState == .fetchFailed)
        }
    }
    
    func testNotificationEventsDidUpdate() {
        cityUserContentSharedWorker.triggerFavoriteEventsUpdate { (error) in }
        XCTAssertTrue(self.didChangeEventFavoritesNotification != 0)
    }
    
    func testNotificationFailedLoadingEvents() {
        cityUserContentSharedWorker.triggerFavoriteEventsUpdate { (error) in }
        XCTAssertTrue(self.favoriteEventsLoadingFailedNotification == 0)
    }
    
    @objc func reactToNotification(notification: Notification) {
        switch notification.name {
        case .didChangeFavoriteEventsDataState:
            didChangeEventFavoritesNotification += 1
            if self.cityUserContentSharedWorker.favoriteEventsDataState.dataLoadingState == .fetchFailed {
                favoriteEventsLoadingFailedNotification += 1
            }
            break
        default:
            break
        }
    }
    
}

private class MockRequest: SCRequestCreating, SCDataFetching {
    func createRequest() -> SCDataFetching {
        return MockRequest()
    }
    
    func fetchData(from url: URL, method: String, body: Data?, needsAuth: Bool, completion: @escaping ((SCRequestResult) -> ())) {
        if url.absoluteString.contains("event") {
            let mockData = favoritesJson.data(using: .utf8)!
            completion(.success(mockData))
        } else if url.absoluteString.contains("cities") {
            let mockData = cityContentJson.data(using: .utf8)!
            completion(.success(mockData))
        } else if url.absoluteString.contains("profile") {
            let mockData = userContentJson.data(using: .utf8)!
            completion(.success(mockData))
        }
        
    }
    
    func uploadData(from url: URL, method: String, body: Data?, needsAuth: Bool, additionalHeaders: [String : String], completion: @escaping ((SCRequestResult) -> ())) {
        
    }
    
    func cancel() {
        
    }
    
    private let userContentJson = """
{
    "content": {
        "accountDisabled": false,
        "accountId": "4.3914607726E11",
        "birthDay": "2003-01-06",
        "cardDisabled": false,
        "cityId": 5,
        "cityName": "Monheim am Rhein",
        "email": "al@featurecode.de",
        "firstName": "Last6",
        "houseNumber": "40770",
        "id": "4NDKYUxTizeVCvqmyco/xRKElY03750esjiXzzjOOi0=",
        "language": "en",
        "lastName": "Test6",
        "libraryId": "00011292",
        "monheimPassCardId": "000100000000000602",
        "street": "Straße6",
        "title": "",
        "userName": "al@featurecode.de",
        "zip": "40770"
    }
}
"""
    
    private let cityContentJson = """
{
    "content": {
        "branchList": [],
        "citizenServiceCategoryList": [{
            "category": "Monheim-Pass",
            "categoryId": 6,
            "citizenServiceList": [{
                "description": "Use many advantages in Monheim with the Monheim Pass, simple and uncomplicated.",
                "function": "monicard",
                "icon": "/img/MonheimPassIcon.png",
                "image": "/img/monheimPass.jpg",
                "isNew": false,
                "language": "en",
                "new": false,
                "residence": true,
                "restricted": true,
                "service": "Monheim-Pass",
                "serviceActions": [],
                "serviceId": 20
            }],
            "description": "Use many advantages in Monheim with the Monheim Pass, simple and uncomplicated.",
            "icon": "/img/wallet_icon.png",
            "image": "/img/tourism_picture.jpg",
            "language": "en"
        }, {
            "category": "Transport",
            "categoryId": 11,
            "citizenServiceList": [{
                "description": " <html>r <body>r <h3>How to buy a ticket?</h3>r <p>This service is currently provided via the Handyticket Deutschland app.</p>r <p>If you already have the Handyticket Deutschland App, you can start buying tickets directly from here.</p>r <h3>Buy ticket M+</h3>r <p>You can conveniently purchase your ticket in the Handyticket Deutschland app using the account of your Monheim Pass.</p>r </bodyr </html>",
                "function": "transport",
                "icon": "/img/opnvicon.png",
                "image": "/img/transportMonheim.jpg",
                "isNew": false,
                "language": "en",
                "new": false,
                "residence": false,
                "restricted": false,
                "service": "Public Transport",
                "serviceActions": [{
                    "action": "2",
                    "actionId": 2,
                    "androidUri": "de.hansecom.htd.android",
                    "buttonDesign": "1",
                    "iosAppStoreUri": "https://apps.apple.com/de/app/handyticket-deutschland/id397986271",
                    "iosUri": "handyticket://",
                    "type": 2,
                    "visibleText": "Open App"
                }],
                "serviceId": 32
            }],
            "description": "With the public transport service you can find stops in your area, select journeys and buy tickets for your public transport journeys.",
            "icon": "/img/wallet_icon.png",
            "image": "/img/transportMonheim.png",
            "language": "en"
        }, {
            "category": "Participation-Portal",
            "categoryId": 14,
            "citizenServiceList": [{
                "description": "<h3>Participate and help shape the future</h3><p>Your commitment is welcome and we offer you the opportunity to play an active role.</p>",
                "function": "mitmach",
                "icon": "/img/mitmachenMonheimIcon.png",
                "image": "/img/mitmachenMonheim.jpg",
                "isNew": false,
                "language": "en",
                "new": false,
                "residence": false,
                "restricted": false,
                "service": "Participation-Portal",
                "serviceActions": [{
                    "action": "1",
                    "actionId": 8,
                    "androidUri": "https://mitdenken.monheim.de/",
                    "buttonDesign": "2",
                    "iosAppStoreUri": "https://mitdenken.monheim.de/",
                    "iosUri": "https://mitdenken.monheim.de/",
                    "type": 2,
                    "visibleText": "Think Along"
                }, {
                    "action": "1",
                    "actionId": 9,
                    "androidUri": "https://www.monheim.de/index.php?id=5301",
                    "buttonDesign": "2",
                    "iosAppStoreUri": "https://www.monheim.de/index.php?id=5301",
                    "iosUri": "https://www.monheim.de/index.php?id=5301",
                    "type": 2,
                    "visibleText": "Planning"
                }, {
                    "action": "1",
                    "actionId": 10,
                    "androidUri": "https://www.civocracy.org/monheim?code=4b5004",
                    "buttonDesign": "2",
                    "iosAppStoreUri": "https://www.civocracy.org/monheim?code=4b5004",
                    "iosUri": "https://www.civocracy.org/monheim?code=4b5004",
                    "type": 2,
                    "visibleText": "Communicate"
                }, {
                    "action": "1",
                    "actionId": 11,
                    "androidUri": "https://www.monheim.de/index.php?id=5960&uri=/bms",
                    "buttonDesign": "2",
                    "iosAppStoreUri": "https://www.monheim.de/index.php?id=5960&uri=/bms",
                    "iosUri": "https://www.monheim.de/index.php?id=5960&uri=/bms",
                    "type": 2,
                    "visibleText": " Report problems"
                }],
                "serviceId": 35
            }],
            "description": "Your commitment is welcome and we offer you the opportunity to play an active role.",
            "icon": "/img/wallet_icon.png",
            "image": "/img/mitmachenMonheim.jpg",
            "language": "en"
        }],
        "cityColor": "#0098DB",
        "cityConfig": {
            "eventsCount": 4,
            "showBranches": false,
            "showCategories": false,
            "showDiscounts": false,
            "showFavouriteMarketplaces": false,
            "showFavouriteServices": false,
            "showHomeDiscounts": false,
            "showHomeOffers": false,
            "showHomeTips": false,
            "showMostUsedMarketplaces": false,
            "showMostUsedServices": false,
            "showNewMarketplaces": false,
            "showNewServices": false,
            "showOurMarketplaces": true,
            "showOurServices": true,
            "showMarketplacesOption": false,
            "showServicesOption": false,
            "stickyNewsCount": 4,
            "yourEventsCount": 2
        },
        "cityContentList": [{
            "contentCategory": "Monheim",
            "contentCreationDate": "2020-02-17 17:59:17",
            "contentDetails": "Im Städtischen Betriebshof an der Robert-Bosch-Straße gab es eine Woche vor Altweiber gleich doppelten Anlass zu feiern: Anlässlich der traditionellen Einweihung des Gänselieselwagens wurde in diesem Rahmen erstmals auch die faire Kamelle an die Monheimer Jecken übergeben. Gleich fünf verschiedene Sorten im Wert von insgesamt 100.000 Euro werden dieses Jahr bei den drei Karnevalsumzügen fliegen. Die Stadtverwaltung wiederholt ihr Engagement für den Fairen Handel im Karneval damit bereits zum dritten Mal.Reichlich mit fairer Kamelle beladen ist auch der nagelneue Wagen von Gänseliesel Betty und Spielmann Sibbe. Das Traditionspaar nahm das farbenfrohe Gefährt während der feierlichen Einweihung von Bürgermeister Daniel Zimmermann entgegen. Am Rosenmontag fahren Gänseliesel und Spielmann damit gemäß des aufgemalten Wagenmottos „Zurück in die Zukunft“. Wagenbaumeister Rolf Jacob und Künstler Stefan Goller setzten die Gänselieselfigur in diesem Jahr zum Wohle des Umweltschutzes aufs Fahrrad.„Rolf Jacob ist im 50. Jahr verantwortlich für den Bau des Gänselieselwagens. Es hat noch nie einen Gänselieselwagen ohne ihn gegeben“, erklärte Bürgermeister Zimmermann. Er dankte Jacob, der sich nun als inzwischen bereits mehrjähriger Rentner aus seinem Dienst rund um den städtischen Karneval verabschiedete, im Namen der Stadtverwaltung und des Rates für seinen Einsatz für das Brauchtum. Mit der Übergabe einer handkolorierten Urkunde ernannte Monheims Stadtoberhaupt Rolf Jacob zudem zum Ehren-Wagenbaumeister und sprach ihm „Dank und Anerkennung für 50 Jahre engagierte und motivierte Organisation“ aus.Die Karnevalistinnen und Karnevalisten sprachen wiederum der Stadtverwaltung vielstimmigen Dank aus. Über 60 Gruppen und Vereine, die an einem oder mehreren der drei Umzüge teilnehmen, durften sich erneut über die Ausstattung mit fairem Wurfmaterial freuen. „Als Fairtrade-Stadt wollen wir auch im Karneval einen Beitrag für bessere Lebens- und Arbeitsbedingungen auf der ganzen Welt leisten“, so Zimmermann. „Wir haben uns daher vor drei Jahren dazu entschieden, die Karnevalsgruppen einheitlich mit Kamelle aus Fairem Handel zu unterstützen. Die Süßigkeiten bereiten an Karneval vielen Kindern hier in Monheim am Rhein eine Freude. Und in den Anbauländern sorgen die fairen Handelsbedingungen dafür, dass Kinder in die Schule gehen können und Zeit zum Spielen haben, statt auf den Feldern arbeiten zu müssen.“ Die Freude an fairer Kamelle verbindet damit die Menschen über Kontinente hinweg.Dieses Jahr folgten elf Gruppen und Vereine dem Aufruf der Stadtverwaltung, auch aus ihrem eigenen Budget faires Wurfmaterial zu bestellen. Gromoka-Sitzungspräsident Moritz Peters appellierte an alle Jecken, das Engagement und die Idee des Fairen Handels weiterzutragen: „Ruht euch nicht auf der Unterstützung der Stadt aus. Wir alle müssen Verantwortung übernehmen und unseren Beitrag dazu leisten, etwas zu verändern.“ Ein fairer Anteil von zehn Prozent ist das erklärte Ziel, für das sich die Jecke Fairsuchung, ein Projekt des Vereins „Tatort – Straßen der Welt“, seit Jahren einsetzt. Christoph Alessio kam als Vertreter des Vereins persönlich vorbei und brachte einen Gruß der Kölner Tatortkommissare Dietmar Bär und Klaus J. Behrendt mit. Die beiden sind seit Jahrzehnten Botschafter für den Fairen Handel und engagieren sich vor allem für Kinderrechte auf den Philippinen. Gemeinsam mit Martin Klupsch vom Fair-Handelszentrum verloste Alessio ein von den Kommissaren signiertes T-Shirt und einen gefüllten Kamelle-Büggel unter den Gruppen, die auch von ihrem eigenen Budget faires Wurfmaterial bestellt hatten.Gemeinsam stimmten sich alle Jecken anschließend bei einem bunten Programm, kühlen Getränken und der beliebten Erbsensuppe der Kin-Wiever-Gardisten auf die Hochphase des Karnevals ein. Neben Prinz Alex I. und Prinzessin Sabi mit ihrem Gefolge sorgten das Kinderprinzenpaar sowie zahlreiche Karnevalsgruppen und Garden mit ihren Tänzen für Stimmung. Mit dabei waren die Marienburg-Garde, die Altstadtfunken, die Rheinstürmer, die Baumberger Dorfgarde und Baumbergs berittene Garde zu Fuß – Kin Wiever. Ebenso heizten die Monheimer Funkenkinder und die Gänselieschen und Spielmänner dem jecken Publikum ordentlich ein. (ts)",
            "contentId": 1114,
            "contentImage": "https://www.monheim.de/fileadmin/osca/06_sport_spiel_3.jpg",
            "contentSource": "https://www.monheim.de/stadtleben-aktuelles/news/nachrichten/gaenseliesel-und-spielmann-fahren-mit-dem-fahrrad-zurueck-in-die-zukunft-8167",
            "contentSubtitle": "Gänseliesel und Spielmann fahren mit dem Fahrrad „Zurück in die Zukunft“",
            "contentTeaser": "Gänseliesel und Spielmann fahren mit dem Fahrrad „Zurück in die Zukunft“",
            "contentTyp": "NEWS",
            "imageCredit": "",
            "language": "de",
            "sticky": false,
            "thumbnail": "https://www.monheim.de/fileadmin/osca/06_sport_spiel_3.jpg",
            "thumbnailCredit": "",
            "uid": "8167"
        }, {
            "contentCategory": "Monheim",
            "contentCreationDate": "2020-02-17 16:37:32",
            "contentDetails": "Nr. 1 – Öffentliche Bekanntmachung der „Richtlinien der Stadt Monheim am Rhein über die Gewährung von Zuwendungen zur Neugestaltung von Fassaden in der historischen Altstadt der Stadt Monheim am Rhein (Förderrichtlinien Fassadenprogramm)“ vom 17.10.2013 in der Fassung der 2. Änderung vom 18.12.2019 p class=",
            "contentId": 1115,
            "contentImage": "https://www.monheim.de/fileadmin/osca/20_politik_1.jpg",
            "contentSource": "https://www.monheim.de/stadtleben-aktuelles/news/nachrichten/amtsblatt-der-stadt-monheim-am-rhein-nr-6-vom-17-februar-2020-8166",
            "contentSubtitle": "Amtsblatt der Stadt Monheim am Rhein Nr. 6 vom 17. Februar 2020",
            "contentTeaser": "Amtsblatt der Stadt Monheim am Rhein Nr. 6 vom 17. Februar 2020",
            "contentTyp": "NEWS",
            "imageCredit": "",
            "language": "de",
            "sticky": false,
            "thumbnail": "https://www.monheim.de/fileadmin/osca/20_politik_1.jpg",
            "thumbnailCredit": "",
            "uid": "8166"
        }, {
            "contentCategory": "Monheim",
            "contentCreationDate": "2020-02-17 15:30:01",
            "contentDetails": "In den kommenden Ferien stehen Kindern und Jugendlichen aus Monheim am Rhein viele spannende Angebote offen. Die Überblickstabellen mit einer großen Auswahl an Workshops, Ausflügen und Freizeiten sind ab sofort auf der städtischen Internetseite einsehbar.Die Kunstschule plant in der ersten Woche der Osterferien, 6. bis 9. April, ganz viel „Zeit für Farbe“ für Kinder ab sechs Jahren und einen Graffiti-Kurs für Jugendliche ab zehn Jahren. Vom 14. bis zum 17. April erleben 10- bis 14-jährige Fotografiefans neue Blickwinkel durch die Linse. In der ersten Woche der Sommerferien, vom 29. Juni bis zum 3. Juli malen Kinder ab sechs Jahren ein Farben-Meer. Dozentin Heike Schwerzel nimmt die Kinder vormittags mit auf eine künstlerische Reise und experimentiert mit bekannten und neuen Materialien. 10- bis 14-Jährige bauen vom 6. bis 10. Juli eine Arche aus Strandgut. Nähere Informationen gibt es unter Telefon 951-4160, oder per E-Mail an kunstschule@monheim.de.Das Römische Museum, die Biologische Station und die Kaltblutpferdezucht Reuter laden in den Osterferien wieder zu aufregenden Aktionstagen ein. Am 6. April erfahren Kinder im Alter von sechs bis zwölf Jahren, wer neben Grasfröschen, Erdkröten und Kaulquappen noch am Wasser lebt. Neun- bis Zwölfjährige können am 7. April lernen, wie man richtig Feuer macht. Im Anschluss gibt es Stockbrot. Am 8. April werden Kinder zu jungen Archäologen und graben mit Pinsel und Kelle Schätze der römischen Antike aus. Die Kaltblutzucht Reuter lockt am 15., 16., und 17. April nachmittags die ganze Familie mit Kutschfahrten. Bevor die Fahrt durch die Kämpe beginnt, wird  das Anspannen der Kaltblutpferde vorgeführt und Wissenswertes zu der alten Pferderasse erläutert. Für alle Angebote ist eine Anmeldung erwünscht. Weitere Informationen gibt es im Internet unter www.hausbuergel.de.Das Ulla-Hahn-Haus organisiert vom 14. bis zum 17. April und vom 30. Juni bis 3. Juli für Kinder ab vier Jahren nachmittags die Leseschaukel. An der Neustraße werden in den Osterferien parallel Detektive gesucht: Am Dienstag, 14. April, können Sechs- bis Neunjährige ein spannendes Abenteuer erleben. In den Sommerferien findet im Ulla-Hahn-Haus vom 6. bis zum 10. Juli eine Schreiboase für 8- bis 14-Jährige statt. Vom 13. bis zum 17. Juli gibt es in Zusammenarbeit mit der Kunstschule unter dem Motto „Plastik Fantastik“ ein weiteres Schreibprojekt für 8- bis 14-Jährige. Nähere Informationen gibt es unter Telefon 951-4140, oder per E-Mail an ullahahnhaus@monheim.de.Wem mehrtägige Angebote zu lang sind, der kann mit dem Team der städtischen Jugendförderung verschiedene Ausflüge unternehmen. In den Osterferien steht am 6. April ein Ausflug ins Langenfelder Sportzentrum zum Bubble Ball auf dem Programm. Am 16. April können Jugendliche ab zwölf Jahren ins Phantasialand fahren. Das „Circus Leben“ auf der Baumberger Bürgerwiese, das die städtische Kinder- und Jugendförderung in den Sommerferien organisiert, ist bereits ausgebucht. Dafür geht vom 30. Juni bis zum 3. Juli das Aktionsmobil auf Tour. Nähere Informationen gibt es bei Fabian Kaina, Telefon 951-5143.Weitere Ausflüge und mehrtägige Jugendfreizeiten der katholischen und evangelischen Kirche, des Arbeiter-Samariter-Bunds, des Jugendklubs Baumberg und anderer Anbietenden finden sich in der Übersicht auf der städtischen Homepage im Bereich „Kinder und Jugend“ unter „Ferienprogramme“. (bh)",
            "contentId": 1116,
            "contentImage": "https://www.monheim.de/fileadmin/_processed_/c/1/csm_20160925tl_Rheinbogen_c008360222.jpg",
            "contentSource": "https://www.monheim.de/stadtleben-aktuelles/news/nachrichten/monheimer-ferien-mit-fotografie-farben-meer-und-stockbrot-am-feuer-8165",
            "contentSubtitle": "Monheimer Ferien mit Fotografie, Farben-Meer und Stockbrot am Feuer",
            "contentTeaser": "Monheimer Ferien mit Fotografie, Farben-Meer und Stockbrot am Feuer",
            "contentTyp": "NEWS",
            "imageCredit": "",
            "language": "de",
            "sticky": false,
            "thumbnail": "https://www.monheim.de/fileadmin/_processed_/c/1/csm_20160925tl_Rheinbogen_c008360222.jpg",
            "thumbnailCredit": "",
            "uid": "8165"
        }, {
            "contentCategory": "Monheim",
            "contentCreationDate": "2020-02-17 14:36:28",
            "contentDetails": "Die Musikschule lädt am Dienstag, 3. März, erneut zur Jazz- und Pop-Session in den Spielmann in der Altstadt ein. Beginn bei freiem Eintritt ist um 19.30 Uhr.Alle sind eingeladen, beim spontanen gemeinsamen Musizieren in lockerer Atmosphäre mitzumachen. Begleitet wird das Ganze wie gewohnt von einer erfahrenen Profi-Band, namentlich Philip Roesler (Klavier), Till Brandt (Bass) und Patrick Westervelt (Schlagzeug). (nj)",
            "contentId": 1117,
            "contentImage": "https://www.monheim.de/fileadmin/_processed_/f/d/csm_20190604JazzSessionSpielmann_81ee762af2.jpg",
            "contentSource": "https://www.monheim.de/stadtleben-aktuelles/news/nachrichten/musikschule-session-im-spielmann-8163",
            "contentSubtitle": "Musikschule: Session im Spielmann",
            "contentTeaser": "Musikschule: Session im Spielmann",
            "contentTyp": "NEWS",
            "imageCredit": "",
            "language": "de",
            "sticky": false,
            "thumbnail": "https://www.monheim.de/fileadmin/_processed_/f/d/csm_20190604JazzSessionSpielmann_81ee762af2.jpg",
            "thumbnailCredit": "",
            "uid": "8163"
        }, {
            "contentCategory": "Monheim",
            "contentCreationDate": "2020-02-17 14:09:35",
            "contentDetails": "Vor allem Pilzbefall ist die Ursache dafür, dass in den nächsten Tagen drei Pappeln am Wasserspielplatz im Rheinbogen gefällt werden müssen. „Die Sicherheit ist gefährdet“, erläutert der städtische Gärtnermeister Jan-Philipp Blume. Vorab hatte ein externer Berater ein Gutachten erstellt. Neue Bäume sind geplant.Nahe dem Deusser-Haus wird ebenfalls gefällt. Unter anderem ist eine Kastanie stark pilzbefallen. Auch dort sind Nachpflanzungen geplant. (nj)",
            "contentId": 1118,
            "contentImage": "https://www.monheim.de/fileadmin/_processed_/9/8/csm_20200217jb_Pappeln_Wasserspielplatz_d5f274205a.jpg",
            "contentSource": "https://www.monheim.de/stadtleben-aktuelles/news/nachrichten/kranke-pappeln-am-wasserspielplatz-muessen-weichen-8162",
            "contentSubtitle": "Kranke Pappeln am Wasserspielplatz müssen weichen",
            "contentTeaser": "Kranke Pappeln am Wasserspielplatz müssen weichen",
            "contentTyp": "NEWS",
            "imageCredit": "",
            "language": "de",
            "sticky": false,
            "thumbnail": "https://www.monheim.de/fileadmin/_processed_/9/8/csm_20200217jb_Pappeln_Wasserspielplatz_d5f274205a.jpg",
            "thumbnailCredit": "",
            "uid": "8162"
        }, {
            "contentCategory": "Monheim",
            "contentCreationDate": "2020-02-17 09:51:25",
            "contentDetails": "Der Karneval fiebert seinem Höhepunkt entgegen. An Altweiber, 20. Februar, und Rosenmontag sind die städtischen Dienststellen geschlossen. Der Donnerstag steht ab 9.11 Uhr ganz im Zeichen des Rathaussturms. Sollte die Verwaltung mit Bürgermeister Daniel Zimmermann an der Spitze kapitulieren müssen, ist im Ratssaal die Schlüsselübergabe an die närrischen Tollitäten vorgesehen. Nach Rede- und Musikbeiträgen geht es weiter in die Altstadt, wo ab 11.11 Uhr der Beginn des Straßenkarnevals gefeiert wird.Das Bürgerbüro bleibt auch am Karnevalssamstag geschlossen. Der Wertstoffhof ist an Altweiber nicht besetzt. In den Mo.Ki-Cafés wird es ebenfalls ruhiger. Rosenmontag ist komplett geschlossen.Bei den Kultureinrichtungen an der Tempelhofer Straße und am Berliner Ring gelten folgende Regelungen: Die Volkshochschule ist von Altweiber bis einschließlich 25. Februar geschlossen. Das gilt auch für die gemeinsame Geschäftsstelle von Ulla-Hahn-Haus und Kunstschule. Die Musikschule schließt an Altweiber und Rosenmontag. Das gilt auch für die Bibliothek.Das Kunden-Center der Monheimer Kulturwerke und Bahnen der Stadt im Monheimer Tor hat Altweiber von 9 bis 14 Uhr geöffnet. Rosenmontag ist geschlossen.Das Mona Mare bleibt Altweiber und Rosenmontag geschlossen. Das Service Center der MEGA an der Rheinpromenade hat Altweiber und den Freitag von 7.30 bis 12.30 geöffnet, Rosenmontag ist geschlossen. (nj)",
            "contentId": 1119,
            "contentImage": "https://www.monheim.de/fileadmin/_processed_/c/a/csm_20190228ts_Rathaussturm_DSC_0228_Ratssaalblick_945fe37e60.jpg",
            "contentSource": "https://www.monheim.de/stadtleben-aktuelles/news/nachrichten/geaenderte-oeffnungszeiten-zum-hoehepunkt-der-jecken-tage-3-8161",
            "contentSubtitle": "Geänderte Öffnungszeiten zum Höhepunkt der jecken Tage",
            "contentTeaser": "Geänderte Öffnungszeiten zum Höhepunkt der jecken Tage",
            "contentTyp": "NEWS",
            "imageCredit": "",
            "language": "de",
            "sticky": true,
            "thumbnail": "https://www.monheim.de/fileadmin/_processed_/c/a/csm_20190228ts_Rathaussturm_DSC_0228_Ratssaalblick_945fe37e60.jpg",
            "thumbnailCredit": "",
            "uid": "8161"
        }, {
            "contentCategory": "Monheim",
            "contentCreationDate": "2020-02-14 13:47:15",
            "contentDetails": "Kleine und große Tollitäten bahnen sich den Weg durch Monheims Feuer- und Rettungswache. Mittendrin Alexander Iffland, Unterbrandmeister in der Freiwilligen Feuerwehr – dieses Mal jedoch in anderer Funktion, als Prinz Alex I.. Gemeinsam mit seiner Prinzessin Sabi und dem gesamten Gefolge sind er und das Kinderprinzenpaar Paula und Marlon der Einladung der Kinderfeuerwehr gefolgt.Wehrleiter Torsten Schlender begrüßte gemeinsam mit Jens Emgenbroich als stellvertretender Leiter der Kinderfeuerwehr die Narrenschar.  Schlender lobte das Engagement des Prinzen, der während des Orkantiefs Sabine seine prinzlichen Pflichten vernachlässigte und stattdessen die Einsatzbereitschaft der Feuerwehr unterstützte. „Auch heute sind wir gerne der Einladung der Kinderfeuerwehr gefolgt und haben dafür eine Verpflichtung in Düsseldorf abgesagt“, berichtet der Prinz. Die Gänselieschen und Spielmänner begeisterten die Zuschauerinnen und Zuschauer mit ihren Tänzen. (bh)",
            "contentId": 1120,
            "contentImage": "https://www.monheim.de/fileadmin/_processed_/5/6/csm_20200211_Besuch_Prinzenpaare_57d0d05923.jpg",
            "contentSource": "https://www.monheim.de/stadtleben-aktuelles/news/nachrichten/naerrische-tollitaeten-besuchen-feuer-und-rettungswache-8158",
            "contentSubtitle": "Närrische Tollitäten besuchen Feuer- und Rettungswache",
            "contentTeaser": "Närrische Tollitäten besuchen Feuer- und Rettungswache",
            "contentTyp": "NEWS",
            "imageCredit": "",
            "language": "de",
            "sticky": false,
            "thumbnail": "https://www.monheim.de/fileadmin/_processed_/5/6/csm_20200211_Besuch_Prinzenpaare_57d0d05923.jpg",
            "thumbnailCredit": "",
            "uid": "8158"
        }, {
            "contentCategory": "Monheim",
            "contentCreationDate": "2020-02-14 12:09:41",
            "contentDetails": "Die Kanal- und Straßenarbeiten für den ersten Abschnitt in der Alten Schulstraße sind so gut wie abgeschlossen. Im Laufe des Dienstagsmorgens, 18. Februar, erfolgt die Freigabe für den Verkehr. Sollte es aufgrund des Wetters am Montag nicht möglich sein, die letzte Asphaltschicht aufzutragen, wird rechtzeitig vor dem Höhepunkt der jecken Tage ein Provisorium geschaffen, um mögliche Stolperfallen zu beseitigen. Die endgültige Asphaltierung erfolgt dann nach Karneval. Im Rahmen der Arbeiten wurden acht neue Bäume in speziellen Wurzelkammersystemen gepflanzt. Es sind Blumeneschen, die als ökologisch wertvoll gelten. Unter anderem sind sie sehr bienenfreundlich. Die Zufahrt zum Rathausparkplatz über die Alte Schulstraße wird im Laufe des Mittwochs wieder freigegeben.Weitere Bäume in Richtung Schelmenturm werden gepflanzt, wenn der zweite Bauabschnitt beginnt. Das wird voraussichtlich Anfang nächsten Jahres der Fall sein, wenn der Rohbau des Gesundheitscampus‘ fertig ist. (nj)",
            "contentId": 1121,
            "contentImage": "https://www.monheim.de/fileadmin/_processed_/2/3/csm_20200214nj_Alte_Schulstrasse_757f6c0d35.jpg",
            "contentSource": "https://www.monheim.de/stadtleben-aktuelles/news/nachrichten/alte-schulstrasse-ab-dienstag-wieder-freigegeben-8157",
            "contentSubtitle": "Alte Schulstraße ab Dienstag wieder freigegeben",
            "contentTeaser": "Alte Schulstraße ab Dienstag wieder freigegeben",
            "contentTyp": "NEWS",
            "imageCredit": "",
            "language": "de",
            "sticky": false,
            "thumbnail": "https://www.monheim.de/fileadmin/_processed_/2/3/csm_20200214nj_Alte_Schulstrasse_757f6c0d35.jpg",
            "thumbnailCredit": "",
            "uid": "8157"
        }, {
            "contentCategory": "Monheim",
            "contentCreationDate": "2020-02-14 10:37:35",
            "contentDetails": "Schon die Allerkleinsten entdecken im Ulla-Hahn-Haus an der Neustraße die Welt der Bücher. Noch gibt es freie Plätze bei den Bücherknirpsen für Kinder von 1,5 bis 3 Jahren. Der nächste Kurs findet vom 2. März bis zum 27. April an insgesamt sieben Terminen montags von 15 bis 16 Uhr im Ulla-Hahn-Haus statt (Kursnummer: K-20S-U201). Wer vorher einmal schnuppern möchte, kann dies mit Voranmeldung am 10. und 17. Februar jeweils von 15 bis 16 Uhr tun.Die Bücherknirpse gibt es zudem am Vormittag. In diesem Kurs haben auch Tageseltern die Möglichkeit sich anzumelden. Noch wenige Restplätze gibt es für den Kurs K-20S-U204 im Mo.Ki-Café Baumberg. Er findet vom 3. März bis 28. April immer dienstags von 10 bis 11 Uhr statt. Ein weiterer Kurs im Ulla-Hahn-Haus startet am Dienstag, 5. Mai und endet am 23. Juni (Kursnummer K-20S-U202).Für Kinder im Alter von vier bis sechs Jahren gibt es außerdem zwei spannende Angebote: Vom 5. März bis zum 2. April gehen die Kinder „Mit dem Geschichtenkoffer auf große Reise“. Birgit Fritz hat jede Menge Geschichten im Gepäck und sammelt an insgesamt fünf Terminen immer donnerstags von 15 bis 16 Uhr mit der Gruppe magische Erinnerungsstücke aus aller Welt (Kursnummer K-20S-U002). „Tierisch was los“ ist dann im Kinderkurs mit Isabel Helmerichs, die vom 4. Mai bis 22. Juni immer montags von 15 bis 16 Uhr die Welt der Tiere erforscht. Von Abenteuern bis zu wilden Karneval-Partys im Zoo haben die tierischen Helden im Bilderbuch viel zu bieten (Kursnummer K-20S-U003).Alle Kurse sind kostenfrei. Anmeldungen nimmt das Ulla-Hahn-Haus über die städtische Internetseite www.monheim.de/ulla-hahn-haus, per E-Mail an ullahahnhaus@monheim.de, telefonisch unter 02173 951-4140 oder persönlich in der gemeinsamen Geschäftsstelle mit der Kunstschule entgegen. (nj)",
            "contentId": 1122,
            "contentImage": "https://www.monheim.de/fileadmin/osca/01_feste_2.jpg",
            "contentSource": "https://www.monheim.de/stadtleben-aktuelles/news/nachrichten/kurse-fuer-kinder-im-ulla-hahn-haus-8156",
            "contentSubtitle": "Kurse für Kinder im Ulla-Hahn-Haus",
            "contentTeaser": "Kurse für Kinder im Ulla-Hahn-Haus",
            "contentTyp": "NEWS",
            "imageCredit": "",
            "language": "de",
            "sticky": false,
            "thumbnail": "https://www.monheim.de/fileadmin/osca/01_feste_2.jpg",
            "thumbnailCredit": "",
            "uid": "8156"
        }, {
            "contentCategory": "Monheim",
            "contentCreationDate": "2020-02-14 10:29:06",
            "contentDetails": "Von Altweiber bis Rosenmontag feiern Jecken, Möhnen und Pänz am liebsten auf der Straße. Den ersten Anlass bietet dazu am Donnerstag, 20. Februar, ab 9.11 Uhr wieder der Sturm aufs Rathaus. Bürgermeister Daniel Zimmermann will den Angreifenden unter dem Kommando der Gromoka aber keinesfalls kampflos weichen. Sollte die Verwaltung dennoch kapitulieren müssen, ist im Ratssaal die Schlüsselübergabe an das Prinzenpaar vorgesehen.Nach Rede- und Musikbeiträgen ziehen Sieger und Besiegte weiter – in diesem Jahr erstmalig nicht zur Doll Eck sondern direkt an den Alten Markt in der Altstadt. Ab 10.30 Uhr organisiert die Gromoka hier eine Altweiberparty. Auf der Bühne stehen neben den Monheimer Garden die Bands Cöllner, Kölsch Fraktion, Kolibris und Mainstream. Die Turmstraße wird von der Kapellenstraße bis zur Hausnummer 20 und die Freiheit ab der Hausnummer 5 für den Verkehr komplett gesperrt. Die Franz-Boehm-Straße wird zur Sackgasse.Am Freitag, 21. Februar, strömen zahlreiche Närrinnen und Narren zum Hitdorfer Karnevalszug, in diesem Jahr unter dem Motto „An jeder Eck ne Hetdörper Jeck“. Die Rheinuferstraße wird ab Alfred-Nobel-Straße halbseitig und ab der Industriestraße voll gesperrt. Start des Hetdörper Schull- und Veedelzochs ist traditionell um 14.33 Uhr. Nach dem Zug werden die Sperrungen wieder aufgehoben.Am Sonntag, 23. Februar, zieht ab 11.11 Uhr der 29. Baumberger Veedelszoch durch den Stadtteil. Aufstellung und Auflösung ist auf dem Garather Weg. Baumberg erklärt in diesem Jahr: „In Monnem weht rejiert, in Boomberg weht jefiert!“ Zahlreiche Straßen sind gesperrt, der Busverkehr wird umgeleitet.Am Nachmittag macht sich ab 14.11 Uhr der 26. Monheimer Kinderkarnevalszug mit Prinzessin Paula und Prinz Marlon auf den Weg durch die Altstadt. Aufstellung und Auflösung ist hier auf der Biesenstraße. Von dort geht es über die Kirchstraße am Schelmenturm vorbei über Frohnstraße, Krummstraße und Alte Schulstraße zurück zur Poststraße.Mit dem 87. Rosenmontagszug erreicht die Session am 24. Februar ab 14.11 Uhr dann ihren Höhepunkt. Unter dem Motto „Kein Kunssjeschmack, doch Kohle satt – Monnem wööd Kulturhauptstadt“ formiert sich der närrische Lindwurm auf der Knipprather Straße und Am Hang. Von dort geht es mit Prinzessin Sabi und Prinz Alex I. auf dem Prinzenwagen in Richtung Stadtmitte und Altstadt. Anders als im Sessionsheft der Gromoka abgedruckt, zieht der Zug wie gewohnt über die Straßen Frohnkamp, Am Steg und Krischerstraße über die Alte Schulstraße. Auf der Kapellenstraße löst sich der Zug auf. Die Stadtmitte ist weiträumig gesperrt, von den Umleitungen sind auch die Buslinien betroffen. Im Anschluss wird im Festzelt auf dem Schützenplatz und in den Gaststätten der Altstadt weitergefeiert. (bh) tDie Stadt appelliert an Anliegende und Autofahrende, die Haltverbote und Absperrungen zu beachten. Im Weg stehende Fahrzeuge müssen notfalls abgeschleppt werden. tDie Zugwege sind im städtischen Terminkalender unter www.monheim.de/freizeit-tourismus/terminkalender veröffentlicht. tDie Busse der Bahnen der Stadt Monheim fahren an den Karnevalstagen Umleitungen. Aktuelle Informationen gibt es auf der Homepage der Bahnen: www.bahnen-monheim.de",
            "contentId": 1123,
            "contentImage": "https://www.monheim.de/fileadmin/_processed_/c/a/csm_2020_Rosenmontagszug_6db19fe06a.jpg",
            "contentSource": "https://www.monheim.de/stadtleben-aktuelles/news/nachrichten/dr-zoch-kuett-jetzt-beginnt-die-zeit-des-strassenkarnevals-8155",
            "contentSubtitle": "D’r Zoch kütt – Jetzt beginnt die Zeit des Straßenkarnevals",
            "contentTeaser": "D’r Zoch kütt – Jetzt beginnt die Zeit des Straßenkarnevals",
            "contentTyp": "NEWS",
            "imageCredit": "",
            "language": "de",
            "sticky": true,
            "thumbnail": "https://www.monheim.de/fileadmin/_processed_/c/a/csm_2020_Rosenmontagszug_6db19fe06a.jpg",
            "thumbnailCredit": "",
            "uid": "8155"
        }, {
            "contentCategory": "Monheim",
            "contentCreationDate": "2020-02-13 11:12:05",
            "contentDetails": "Die Bauarbeiten auf der Kreuzung Berliner Ring / Heerweg sind abgeschlossen. Ab Samstag, 15. Februar, wird der Bereich vollständig freigegeben.Die Straßenbaumaßnahme hat etwas über ein Jahr gedauert. Dabei wurde der Kreisverkehr Bleer Straße / Berliner Ring inklusive Kunstwerk „Haste Töne“ erstellt und der Berliner Ring bis zur Kreuzung Heerweg saniert. Es wurden unter Anderem vier Bushaltestellen barrierefrei ausgebaut und ein neuer Kanal im Heerweg verlegt. (nj)",
            "contentId": 1124,
            "contentImage": "https://www.monheim.de/fileadmin/osca/06_sport_spiel_2.jpg",
            "contentSource": "https://www.monheim.de/stadtleben-aktuelles/news/nachrichten/berliner-ring-ab-samstag-wieder-frei-befahrbar-8152",
            "contentSubtitle": "Berliner Ring ab Samstag wieder frei befahrbar",
            "contentTeaser": "Berliner Ring ab Samstag wieder frei befahrbar",
            "contentTyp": "NEWS",
            "imageCredit": "",
            "language": "de",
            "sticky": false,
            "thumbnail": "https://www.monheim.de/fileadmin/osca/06_sport_spiel_2.jpg",
            "thumbnailCredit": "",
            "uid": "8152"
        }, {
            "contentCategory": "Monheim",
            "contentCreationDate": "2020-02-12 11:16:16",
            "contentDetails": "Der Klimawandel ist inzwischen zentrales Thema der politischen Debatte, sowohl national als auch international. Er ist eine potentielle Bedrohung. Aber wie konnte es so weit kommen? Und ist das alles tatsächlich so dramatisch? In dem Vortrag „Klimawandel: Ursachen und Folgen“ wird Dr. Volker Ossenkopf-Okada vom Physikalischen Institut der Universität Köln diese und andere Fragen zum Thema am Dienstag, 18. Februar, behandeln. Beginn bei freiem Eintritt im Bergischen Saal des Rathauses ist um 18.30 Uhr.Die Veranstaltung ist eine Kooperation der Monheimer Artenschutz-Initiative (MOA) mit der Stadt Monheim am Rhein. (nj)",
            "contentId": 1125,
            "contentImage": "https://www.monheim.de/fileadmin/_processed_/f/0/csm_MEGA_Solardach_281e1c1853.jpg",
            "contentSource": "https://www.monheim.de/stadtleben-aktuelles/news/nachrichten/vortrag-ueber-den-klimawandel-8151",
            "contentSubtitle": "Vortrag über den Klimawandel",
            "contentTeaser": "Vortrag über den Klimawandel",
            "contentTyp": "NEWS",
            "imageCredit": "",
            "language": "de",
            "sticky": false,
            "thumbnail": "https://www.monheim.de/fileadmin/_processed_/f/0/csm_MEGA_Solardach_281e1c1853.jpg",
            "thumbnailCredit": "",
            "uid": "8151"
        }, {
            "contentCategory": "Monheim",
            "contentCreationDate": "2020-02-12 10:38:35",
            "contentDetails": "Ende Januar fand erstmalig in der Monheimer Musikschule der Regional-Wettbewerb „Jugend musiziert“ statt. Fast 30 Teilnehmende der Monheimer Musikschule konnten bei diesem Wettbewerb erste und zweite Plätze erreichen. Felix Palt und Maithili Joshi (beide Gitarre Pop) schafften sogar die Qualifikation für den Landeswettbewerb und werden sich im März in der Essener Musikhochschule mit den besten Nachwuchstalenten aus ganz NRW messen. Das gilt ebenso für den Monheimer Bjarne Drechsel, der als Gast beim Preisträgerkonzert der Musikschule mitwirken wird. Zuvor findet bei freiem Eintritt am Dienstag, 18. Februar, das Monheimer Preisträgerkonzert statt, bei dem die jungen Talente eine Kostprobe ihres Könnens geben werden und Bürgermeister Daniel Zimmermann alle diesjährigen Teilnehmenden ehren wird. Beginn im Saal der Musik- und Kunstschule am Berliner Ring 9 ist um 18 Uhr.Bei den weiteren Preisträgerinnen und Preisträgern aus Monheim am Rhein handelt es sich um die Pianistinnen und Pianisten Jenny Jäger, Theresa Jung, Johann Koch (alle zweite Preise), Zico Kraeplin, Sophia Morlock, Oskar Albrecht und Christina Ruchay (alle erste Preise). Außerdem wurden an die Teilnehmenden im Bereich Gitarre (Pop) Maithili Joshi, Nikolaus Kautz, Felix Palt und Anne Ruhnau-Wiebusch erste Preise vergeben. Auch in der Kategorie Schlagzeug wurden erste Preise von Maximilian Cziborra und Laura Winnen erzielt. Lilly Ruhnau-Wiebusch erlangte einen ersten Preis im Fach Gesang und zudem einen zweiten Preis zusammen mit Ellen Beiermann und Karolina Hollon als Querflötentrio. Ebenfalls ausgezeichnet mit einem zweiten Preis wurde das Blechbläserquintett Maike Bachhausen, Noel Serve, Virginia Wilk, Niklas Scharenberg und Ayyoub Marbia. Luzie Gersonde, Maya Sperling und Marah Westholt erzielten als Holzbläsertrio einen ersten Preis, ebenso wie die Saxophonistin Amelie Behrendt zusammen mit ihrem Spielpartner aus der Leichlinger Musikschule Moritz von Nieswandt. Eine zweite städteübergreifende Zusammenarbeit der Geigerinnen Ricarda Kohlert und Zofia Yp von der Leverkusener Musikschule wurde ebenfalls mit einem ersten Preis bedacht. (nj)",
            "contentId": 1126,
            "contentImage": "https://www.monheim.de/fileadmin/_processed_/3/d/csm_Lilly_Ruhnau_Wiebusch_e45552bda9.jpg",
            "contentSource": "https://www.monheim.de/stadtleben-aktuelles/news/nachrichten/jugend-musiziert-preistraegerkonzert-am-dienstag-8150",
            "contentSubtitle": "„Jugend musiziert“: Preisträgerkonzert am Dienstag",
            "contentTeaser": "„Jugend musiziert“: Preisträgerkonzert am Dienstag",
            "contentTyp": "NEWS",
            "imageCredit": "",
            "language": "de",
            "sticky": false,
            "thumbnail": "https://www.monheim.de/fileadmin/_processed_/3/d/csm_Lilly_Ruhnau_Wiebusch_e45552bda9.jpg",
            "thumbnailCredit": "",
            "uid": "8150"
        }, {
            "contentCategory": "Monheim",
            "contentCreationDate": "2020-02-11 17:55:46",
            "contentDetails": "Statt Asche nun ein nagelneuer Kunstrasenplatz: Bürgermeister Daniel Zimmermann weihte am heutigen Dienstag, 11. Februar, die Spielstätte im Häck-Stadion an der Lichtenberger Straße ein. „Nun hat auch der letzte Monheimer Verein für seine Fußballer einen Kunstrasenplatz“, so das Stadtoberhaupt. „Ein Traum wird wahr“, freute sich Erhan Güneser, Vorsitzender des Vereins Inter Monheim, der den Platz hauptsächlich nutzen wird.Zudem wird in den nächsten Monaten eine Kunststofflaufbahn für den Schulsport fertiggestellt. Die Gesamtkosten belaufen sich auf etwa 1,7 Millionen Euro. Außerdem sind bereits neue Umkleidekabinen in Bau, die voraussichtlich ab dem Sommer nutzbar sein werden. Dafür investiert die Stadt nochmals fast 800.000 Euro. (nj)",
            "contentId": 1127,
            "contentImage": "https://www.monheim.de/fileadmin/_processed_/1/0/csm_20200211nj_Einweihung_Kunstrasenplatz_Haeck_Stadion_4c9c0bc547.jpg",
            "contentSource": "https://www.monheim.de/stadtleben-aktuelles/news/nachrichten/asche-ade-kunstrasenplatz-im-haeck-stadion-8149",
            "contentSubtitle": "Asche ade: Kunstrasenplatz im Häck-Stadion",
            "contentTeaser": "Asche ade: Kunstrasenplatz im Häck-Stadion",
            "contentTyp": "NEWS",
            "imageCredit": "",
            "language": "de",
            "sticky": false,
            "thumbnail": "https://www.monheim.de/fileadmin/_processed_/1/0/csm_20200211nj_Einweihung_Kunstrasenplatz_Haeck_Stadion_4c9c0bc547.jpg",
            "thumbnailCredit": "",
            "uid": "8149"
        }],
        "cityId": 5,
        "cityName": "Monheim am Rhein",
        "cityPicture": "/img/headerMonheim.jpg",
        "cityPreviewPicture": "/img/headerprevMonheim.jpg",
        "cityNightPicture": "/img/headerprevMonheim.jpg",
        "cityWeather": {
            "atmosphericPressure": 1022,
            "cityId": 5,
            "cityKey": 2869791,
            "cloudiness": 75,
            "description": "broken clouds",
            "humidity": 70,
            "id": 8,
            "language": "en",
            "maximumTemperature": 9.0,
            "minimumTemperature": 7.0,
            "rainVolume": 0,
            "sunrise": "1970-01-19 08:26:48",
            "sunset": "1970-01-19 08:27:25",
            "temperature": 8.0,
            "visibility": 10000,
            "windDirection": 230,
            "windSpeed": 9.3
        },
        "country": "Germany",
        "marketplacePicture": "/img/header_Marktplatz_Monheim.jpg",
        "municipalCoat": "/img/logo_monheim3x.png",
        "postalCode": 40789,
        "postalCodeList": [{
            "zipCode": 40789
        }],
        "servicePicture": "/img/headerBuergerserviceMonheim.jpg",
        "stateName": "Nordrhein-Westfalen"
    }
}
"""
    
    private let favoritesJson = """
{
    "content": [{
        "cityEventCategories": [{
            "categoryName": "Jugendliche",
            "id": 17
        }, {
            "categoryName": "Kinder",
            "id": 16
        }, {
            "categoryName": "Kunst & Kultur",
            "id": 10
        }],
        "description": "Ende Januar fand erstmalig in der Monheimer Musikschule der Regional-Wettbewerb „Jugend musiziert“ statt. Fast 30 Teilnehmende der Monheimer Musikschule konnten bei diesem Wettbewerb erste und zweite Plätze erreichen.Bjarne Drechsel (Schlagzeug) sowie Felix Palt und Maithili Joshi (beide Gitarre Pop) schafften sogar die Qualifikation für den Landeswettbewerb und werden sich im März in der Essener Musikhochschule mit den besten Nachwuchstalenten aus ganz NRW messen. Zuvor findet bei freiem Eintritt am Dienstag, 18. Februar, das Monheimer Preisträgerkonzert statt, bei dem die jungen Talente eine Kostprobe ihres Könnens geben werden.Zuvor ehrt Bürgermeister Daniel Zimmermann alle diesjährigen Teilnehmenden.",
        "endDate": "2020-02-18 18:00:00",
        "eventId": "5446",
        "hasEndTime": false,
        "hasStartTime": true,
        "image": "https://www.monheim.de/fileadmin/_processed_/3/d/csm_Lilly_Ruhnau_Wiebusch_e45552bda9.jpg",
        "imageCredit": "",
        "language": "de",
        "latitude": 51.0838396,
        "link": "https://www.monheim.de/freizeit-tourismus/terminkalender/termin/jugend-musiziert-preistraegerkonzert-5446",
        "locationAddress": "Berliner Ring 9, 40789 Monheim am Rhein",
        "locationName": "Musik- und Kunstschule",
        "longitude": 6.888556,
        "pdf": [],
        "startDate": "2020-02-18 18:00:00",
        "subtitle": "„Jugend musiziert“-Preisträgerkonzert",
        "thumbnail": "https://www.monheim.de/fileadmin/_processed_/3/d/csm_Lilly_Ruhnau_Wiebusch_e45552bda9.jpg",
        "thumbnailCredit": "",
        "title": "„Jugend musiziert“-Preisträgerkonzert",
        "uid": "477"
    }]
}
"""

}
