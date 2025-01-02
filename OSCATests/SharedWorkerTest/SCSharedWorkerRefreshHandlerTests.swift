//
//  SCSharedWorkerRefreshHandlerTests.swift
//  SmartCityTests
//
//  Created by Alexander Lichius on 19.02.20.
//  Copyright © 2020 Deutsche Telekom AG - VTI Organization. All rights reserved.
//

import XCTest
//@testable import SmartCity
@testable import OSCA

class SCSharedWorkerRefreshHandlerTests: XCTestCase {
    //let injector = SCInjector()
    var sharedRefreshHandler: SCSharedWorkerRefreshHandler!
    var cityContentSharedWorker: SCCityContentSharedWorking!
    var appContentSharedWorker: SCAppContentSharedWorking!
    var userContentSharedWorker: SCUserContentSharedWorking!
    var userCityContentSharedWorker: SCUserCityContentSharedWorking!
    var basicPOIGuideWorker: SCBasicPOIGuideWorking!

    var authProvider: (SCAuthTokenProviding & SCLogoutAuthProviding)!
    
    override func setUp() {
        self.cityContentSharedWorker = SCCityContentSharedWorker(requestFactory: MockRequest())
        self.appContentSharedWorker = SCAppContentSharedWorker(requestFactory: MockRequest())
        self.userContentSharedWorker = SCUserContentSharedWorker(requestFactory: MockRequest())
        self.userCityContentSharedWorker = SCUserCityContentSharedWorker(requestFactory: MockRequest(), cityIdentifier: self.cityContentSharedWorker, userIdentifier: self.userContentSharedWorker)
        self.basicPOIGuideWorker = SCBasicPOIGuideWorker(requestFactory: MockRequest())

        self.authProvider = SCAuth()
        self.sharedRefreshHandler = SCSharedWorkerRefreshHandler(cityContentSharedWorker: cityContentSharedWorker, userContentSharedWorker: userContentSharedWorker, userCityContentSharedWorker: userCityContentSharedWorker, appContentSharedWorker: appContentSharedWorker, authProvider: authProvider, display: nil)
    }
    
    func testReloadCities() {
        let availableExpectation = expectation(description: "cities and user data available")
        self.sharedRefreshHandler.reloadContent(force: true)
        SCUtilities.delay(withTime: 0.5) {
            if self.cityContentSharedWorker.citiesDataState.dataInitialized {
                availableExpectation.fulfill()
            }
        }
        wait(for: [availableExpectation], timeout: 2.0)
    }
    
    func testReloadTerms() {
        let availableExpectation = expectation(description: "terms available")
        self.sharedRefreshHandler.reloadContent(force: true)
        SCUtilities.delay(withTime: 0.5) {
            if self.appContentSharedWorker.getTermsAndConditions() != nil{
                availableExpectation.fulfill()
            }
        }
        wait(for: [availableExpectation], timeout: 2.0)
    }

}

private class MockRequest: SCRequestCreating, SCDataFetching {
    func createRequest() -> SCDataFetching {
        return MockRequest()
    }

    func fetchData(from url: URL, method: String, body: Data?, needsAuth: Bool, completion: @escaping ((SCRequestResult) -> ())) {
        if url.absoluteString.lowercased().contains("get_allcities") {
            let mockData = citiesJson.data(using: .utf8)!
            completion(.success(mockData))
        } else if url.absoluteString.lowercased().contains("cities") {
            let mockData = cityContentJson.data(using: .utf8)!
            completion(.success(mockData))
        } else if url.absoluteString.contains("terms") {
            let mockData = termsJson.data(using: .utf8)!
            completion(.success(mockData))
        }

    }
    
    func uploadData(from url: URL, method: String, body: Data?, needsAuth: Bool, additionalHeaders: [String : String], completion: @escaping ((SCRequestResult) -> ())) {
        
    }
    
    func cancel() {

    }
        
    private let citiesJson = """
    {
        "content": [
            {
                "cityColor": "#FF0000",
                "cityId": 2,
                "cityName": "München",
                "cityPicture": "/img/headerMonheim.jpg",
                "cityPreviewPicture": "/img/headerprevMonheim.jpg",
                "cityNightPicture": "/img/headerprevMonheim.jpg",
                "country": "Germany",
                "municipalCoat": "/img/logo_monheim3x.png",
                "postalCode": [
                    "80331",
                    "81929"
                ],
                "servicePicture": "/img/headerBuergerservicfeMonheim.jpg",
                "stateName": "Bavaria",
                "latitude": 0.0,
                "longitude": 0.0
            },
            {
                "cityColor": "#AFC541",
                "cityId": 6,
                "cityName": "Bingöl",
                "cityPicture": "/img/MonheimPassIcon.png",
                "cityPreviewPicture": "/img/MonheimPassIcon.png",
                "cityNightPicture": "/img/MonheimPassIcon.png",
                "country": "Ağrı",
                "municipalCoat": "/img/MonheimPassIcon.png",
                "postalCode": [
                    "93333"
                ],
                "servicePicture": "/img/MonheimPassIcon.png",
                "stateName": "Hakkâri",
                "latitude": 0.0,
                "longitude": 0.0
            },
            {
                "cityColor": "#7141C5",
                "cityId": 7,
                "cityName": "Baden-Württemberg",
                "cityPicture": "/img/monheimPass.jpg",
                "cityPreviewPicture": "/img/monheimPass.jpg",
                "cityNightPicture": "/img/monheimPass.jpg",
                "country": "Altötting",
                "municipalCoat": "/img/monheimPass.jpg",
                "postalCode": [
                    "72568",
                    "72985",
                    "78954"
                ],
                "servicePicture": "/img/monheimPass.jpg",
                "stateName": "Weiß Ferdl ",
                "latitude": 0.0,
                "longitude": 0.0
            },
            {
                "cityColor": "fdsfsfs",
                "cityId": 11,
                "cityName": "abc",
                "cityPicture": "abc",
                "cityPreviewPicture": "abc",
                "cityNightPicture": "abc",
                "country": "df",
                "municipalCoat": "abc",
                "postalCode": [
                    "1223"
                ],
                "servicePicture": "abc",
                "stateName": "sad",
                "latitude": 0.0,
                "longitude": 0.0
            },
            {
                "cityColor": "#fefefe",
                "cityId": 13,
                "cityName": "pune",
                "cityPicture": "test",
                "cityPreviewPicture": "test",
                "cityNightPicture": "test",
                "country": "india",
                "municipalCoat": "test",
                "postalCode": [
                    "11111"
                ],
                "servicePicture": "test",
                "stateName": "maharashtra",
                "latitude": 0.0,
                "longitude": 0.0
            },
            {
                "cityColor": "#D50000",
                "cityId": 17,
                "cityName": "Dortmund ",
                "cityPicture": "/img/headerDortmund.png",
                "cityPreviewPicture": "/img/headerprevDortmund.jpg",
                "cityNightPicture": "/img/headerprevDortmund.jpg",
                "country": "Germany ",
                "municipalCoat": "/img/municipalCoatDortmund.png",
                "postalCode": [
                    "44135",
                    "44137",
                    "44139",
                    "44141",
                    "44143",
                    "44145",
                    "44147",
                    "44149",
                    "44225",
                    "44227",
                    "44229",
                    "44263",
                    "44265",
                    "44267",
                    "44269",
                    "44287",
                    "44289",
                    "44309",
                    "44319",
                    "44328",
                    "44329",
                    "44339",
                    "44357",
                    "44359",
                    "44369",
                    "44379",
                    "44388"
                ],
                "servicePicture": "/img/headerBuergerServiceDortmund.jpg",
                "stateName": "North Rhine-Westphalia",
                "latitude": 0.0,
                "longitude": 0.0
            }
        ]
    }
    """
        

    private let termsJson = """

{
    "content": {
        "dataSecurity": {
            "adjustLink": "https://www.adjust.com/terms/gdpr/",
            "dataUsage": "<h2 style=text-align:center;><strong>Datenschutzhinweis der T-Systems International GmbH (&bdquo;Telekom&ldquo;) f&uuml;r die Nutzung der MONHEIM-PASS App</strong></h2><h2><strong>Allgemeines</strong></h2><p>Der Schutz Ihrer pers&ouml;nlichen Daten hat f&uuml;r die die T-Systems International GmbH einen hohen Stellenwert einen hohen Stellenwert. Es ist uns wichtig, Sie dar&uuml;ber zu informieren, welche pers&ouml;nlichen Daten erfasst werden, wie diese verwendet werden und welche Gestaltungsm&ouml;glichkeiten Sie dabei haben.</p><p><strong>1. Welche Daten werden erfasst, wie werden sie verwendet und wie lange werden sie gespeichert?</strong></p><p><strong>Bei der Nutzung der App:</strong> Wenn Sie die App nutzen, verzeichnen unsere Server tempor&auml;r die IP-Adresse Ihres Ger&auml;tes und andere technische Merkmale, wie zum Beispiel die angefragten Inhalte (Art. 6 Abs. 1 b DSGVO).</p><p>In dieser App haben Sie die M&ouml;glichkeit neben den Eingaben per Tastatur auch den Text zu diktieren. Die Spracheingabe (Google) oder Diktierfunktion (Apple) ist eine Funktionalit&auml;t, die das Betriebssystem unserer App zur Verf&uuml;gung stellt. Bei der Verwendung wird die Sprache durch einen Dritten (z. B. Apple oder Google) als Verantwortlichen verarbeitet und das Ergebnis an unsere App geliefert und im Eingabefeld ausgegeben. Zu Details zu der Funktionalit&auml;t, und wie Sie die Nutzung ein- bzw. ausschalten k&ouml;nnen, informieren Sie sich bitte bei dem jeweiligen Betriebssystemhersteller.</p><p><strong>2. Berechtigungen</strong></p><p>Um die App auf Ihrem Ger&auml;t nutzen zu k&ouml;nnen, muss die App auf verschiedene Funktionen und Daten Ihres Endger&auml;ts zugreifen k&ouml;nnen. Dazu ist es erforderlich, dass Sie bestimmte Berechtigungen erteilen (Art. 6 Abs. 1 a DSGVO).<br />Die Berechtigungen sind von den verschiedenen Herstellern unterschiedlich programmiert. So k&ouml;nnen z. B. Einzelberechtigungen zu Berechtigungskategorien zusammengefasst sein und Sie k&ouml;nnen auch nur der Berechtigungskategorie insgesamt zustimmen.<br />Bitte beachten Sie, dass Sie im Falle eines Widerspruchs einer oder mehrerer Berechtigungen gegebenenfalls nicht s&auml;mtliche Funktionen unserer App nutzen k&ouml;nnen.</p><p><strong>Kalender</strong><br />Die App ben&ouml;tigt Zugriff auf einen Kalender um einen Termin hinzuf&uuml;gen zu k&ouml;nnen.</p><p><strong>Internetkommunikation</strong><br />Die App ben&ouml;tigt Zugriff auf das Internet &uuml;ber W-LAN oder Mobilfunk um Ihnen den Zugriff auf die bereitgestellten Dienste zu erm&ouml;glichen.</p><p><strong>3. Sendet die App Push-Benachrichtigungen?</strong></p><p>Push-Benachrichtigungen sind Nachrichten, die von der App auf Ihr Ger&auml;t gesendet und dort priorisiert dargestellt werden. Diese App verwendet Push-Benachrichtigungen im Auslieferungszustand, sofern Sie bei der App-Installation oder bei der ersten Nutzung eingewilligt haben (Art. 6 Abs. 1 a DSGVO).<br />Sie k&ouml;nnen den Empfang von Push-Benachrichtigungen jederzeit in den Einstellungen Ihres Ger&auml;tes deaktivieren.<br />Die Abwicklung erfolgt &uuml;ber die Auftragsverarbeiter <a href=https://www.moengage.com/>MoEngage</a>.</p><p><br /><strong>4. Wird mein Nutzungsverhalten ausgewertet, z. B. f&uuml;r Werbung oder Tracking?</strong></p><p><strong>Erl&auml;uterungen und Definitionen:</strong><br />Wir m&ouml;chten, dass sie unsere App gerne nutzen und unsere Produkte und Dienste in Anspruch nehmen. Daran haben wir ein wirtschaftliches Interesse. Damit sie die Produkte finden, die sie interessieren und wir unsere App nutzerfreundlich ausgestalten k&ouml;nnen, analysieren wir anonymisiert oder pseudonymisiert ihr Nutzungsverhalten. Im Rahmen der gesetzlichen Regelungen legen wir, oder von uns im Rahmen einer Auftragsdatenverarbeitung beauftragte Unternehmen, Nutzungsprofile an. Ein unmittelbarer R&uuml;ckschluss auf Sie ist dabei nicht m&ouml;glich. Nachfolgend informieren wir Sie allgemein &uuml;ber die verschiedenen Zwecke. &Uuml;ber die Datenschutz-Einstellungen haben sie die M&ouml;glichkeit der Tool-Nutzung zuzustimmen oder diese abzulehnen. Tools, die zur Erbringung der App erforderlich sind, (siehe Erl&auml;uterung unter 1)) k&ouml;nnen nicht abgelehnt werden.</p><p><strong>Tag-Management (erforderlich)</strong><br />Das Tag-Management dient der Verwaltung von Tracking-Tools in Apps. Dazu wird f&uuml;r jede Seite eine Markierung (engl. Tag) festgelegt. Anhand der Markierung kann dann festgelegt werden, welche Tracking-Tools f&uuml;r diese Seite zum Einsatz kommen sollen. &Uuml;ber das Tag-Management kann somit das Tracking gezielt gesteuert werden, sodass die Tools nur dort zum Einsatz kommen, wo sie Sinn ergeben.</p><p><strong>Marktforschung / Reichweitenmessung (Opt-In)</strong><br />Ziel der Reichweitenmessung ist es, die Nutzungsintensit&auml;t und die Anzahl der Nutzer einer App statistisch zu bestimmen sowie vergleichbare Werte f&uuml;r alle angeschlossenen Angebote zu erhalten. Zu keinem Zeitpunkt werden einzelne Nutzer identifiziert. Ihre Identit&auml;t bleibt immer gesch&uuml;tzt.</p><p><strong>Zur Verbesserung der technischen App-Qualit&auml;t (Opt-In)</strong> <br />Um die Qualit&auml;t der Programmierung einer App zu messen oder Abst&uuml;rze und deren Ursache zu registrieren werden Programmablauf und Nutzungsverhalten ausgewertet. Einzelne Nutzer werden dabei nicht identifiziert.</p><p><strong>Profile zur bedarfsgerechten Gestaltung der App (Opt-In)</strong><br />Um die App stetig verbessern zu k&ouml;nnen, erstellen wir sogenannte Clickstream-Analysen. Der Clickstream entspricht Ihrem Bewegungspfad in der App. Die Analyse der Bewegungspfade gibt uns Aufschluss &uuml;ber das Nutzungsverhalten der App. Dieses l&auml;sst uns m&ouml;gliche Strukturfehler in der App erkennen und so die App verbessern, damit die App auf Ihre Bed&uuml;rfnisse zu optimieren. Zu keinem Zeitpunkt werden einzelne Nutzer identifiziert.</p><p><strong>Profile f&uuml;r personalisierte Empfehlungen (Opt-In)</strong><br />Die MONHEIM-PASS APP spielt Ihnen individuell angepasste, personalisierte, Handlungs- und Klick-Empfehlungen f&uuml;r Angebote, Dienste oder Produkte aus. Dazu legt der Dienstleister ein pseudonymes Profil &uuml;ber die von Ihnen aufgerufenen Dienste und Seiten der App an und ordnet diesem Kategorien zu. Sie erhalten zum Profil passende Inhalte oder Hinweise angezeigt. Zu keinem Zeitpunkt werden einzelne Nutzer identifiziert oder personenbezogene Daten f&uuml;r das Profil verwendet.</p><p><br /><strong>a) Analytische Tools</strong><br />Diese Tools helfen uns, das Nutzungsverhalten besser zu verstehen. <br />Analysetools erm&ouml;glichen die Erhebung von Nutzungs- und Erkennungsm&ouml;glichkeiten durch Erst- oder Drittanbieter, in so genannten pseudonymen Nutzungsprofilen. Wir benutzen beispielsweise Analysetools, um die Zahl der individuellen Nutzer einer App zu ermitteln oder um technische Informationen bei einem Absturz der App zu erheben, als auch das Nutzerverhalten auf Basis anonymer und pseudonymer Informationen zu analysieren, wie Nutzer mit der App interagieren. Ein unmittelbarer R&uuml;ckschluss auf eine Person ist dabei nicht m&ouml;glich. Rechtsgrundlage f&uuml;r diese Tools ist Art. 6 Abs. 1 a DSGVO.</p>",
            "description": "<p><strong>b) Dienste von anderen Unternehmen (eigenverantwortliche Drittanbieter)</strong></p><p>Auf einigen Seiten unserer App haben wir Drittanbieter Dienste eingebunden, die ihren Services eigenverantwortlich erbringen. Dabei werden bei der Nutzung unserer App Daten mithilfe von Tools erfasst und an den jeweiligen Dritten &uuml;bermittelt. Rechtsgrundlage f&uuml;r diese Tools ist Art. 6 Abs. 1 a DSGVO. In welchem Umfang, zu welchen Zwecken und auf Basis welcher Rechtsgrundlage eine Weiterverarbeitung zu eigenen Zwecken des Drittanbieters erfolgt, entnehmen Sie bitte den Datenschutzhinweisen des Drittanbieters. Die Informationen zu den eigenverantwortlichen Drittanbietern finden Sie nachfolgend. <br /> <br /><strong>Google</strong></p><p>Auf einzelnen Seiten setzen wir Google Maps zur Darstellung von Karten, Standorten und f&uuml;r die Routenplanung ein. Betrieben wird Google Maps von Google Inc., 1600 Amphitheatre Parkway, Mountain View, CA 94043, USA. Durch die Einbettung von Google Maps wird ihre IP-Adresse unmittelbar an Google &uuml;bertragen und gespeichert, sobald Sie eine solche Seite besuchen. Sie k&ouml;nnen sich jederzeit &uuml;ber die Datenverarbeitung durch Google unter <a href=http://www.google.de/intl/de/policies/privacy>http://www.google.de/intl/de/policies/privacy</a> informieren und dieser widersprechen.</p><p><strong>Zugangsdaten</strong></p><p>Sollten Sie unter Android &bdquo;Smart Lock&ldquo; oder unter iOS &bdquo;Keychain&ldquo; aktiviert haben, so werden Ihre Zugangsdaten in der jeweiligen Cloud gespeichert. Dies ist eine Funktion des jeweiligen Betriebssystems und wird nicht von der MONHEIM-PASS App selbst zur Verf&uuml;gung gestellt. <br />Weitere Informationen zu Android &bdquo;Smart Lock&ldquo; und iOS &bdquo;Keychain&ldquo; erhalten Sie bei dem jeweiligen Hersteller Ihres Smartphones.</p><p><strong>5. Wo finde ich die Informationen, die f&uuml;r mich wichtig sind?</strong></p><p>Dieser <strong>Datenschutzhinweis</strong> gibt einen &Uuml;berblick &uuml;ber die Punkte, die f&uuml;r die Verarbeitung Ihrer Daten in dieser App durch die Telekom gelten.</p><p>Weitere Informationen, auch zum Datenschutz in speziellen Produkten, erhalten Sie auf <a href=https://www.telekom.com/de/verantwortung/datenschutz-und-datensicherheit/datenschutz>https://www.telekom.com/de/verantwortung/datenschutz-und-datensicherheit/datenschutz</a> und unter <a href=http://www.telekom.de/datenschutzhinweise>http://www.telekom.de/datenschutzhinweise</a>.</p><p><strong>6. Wer ist verantwortlich f&uuml;r die Datenverarbeitung? Wer ist mein Ansprechpartner, wenn ich Fragen zum Datenschutz bei der Telekom habe?</strong></p><p>Datenverantwortliche ist die T-Systems International GmbH, Hahnstra&szlig;e 43d, 60528 Frankfurt am Main. Bei Fragen k&ouml;nnen Sie sich an unseren Kundenservice wenden oder an unseren Datenschutzbeauftragten, Herrn Dr. Claus D. Ulmer, Friedrich-Ebert-Allee 140, 53113 Bonn, <a href=mailto:datenschutz@telekom.de>datenschutz@telekom.de</a>.</p><p><strong>7. Welche Rechte habe ich?</strong></p><p>Sie haben das Recht, <br/>a) <strong>Auskunft</strong> zu verlangen zu Kategorien der verarbeiteten Daten, Verarbeitungszwecken, etwaigen Empf&auml;ngern der Daten, der geplanten Speicherdauer (Art. 15 DSGVO);<br/>b) die <strong>Berichtigung</strong> bzw. Erg&auml;nzung unrichtiger bzw. unvollst&auml;ndiger Daten zu verlangen (Art. 16 DSGVO); <br />c) eine erteilte Einwilligung jederzeit mit Wirkung f&uuml;r die Zukunft zu <strong>widerrufen</strong> (Art. 7 Abs. 3 DSGVO);<br />d) einer Datenverarbeitung, die aufgrund eines berechtigten Interesses erfolgen soll, aus Gr&uuml;nden zu <strong>widersprechen</strong>, die sich aus Ihrer besonderen Situation ergeben (Art 21 Abs. 1 DSGVO);<br />e) in bestimmten F&auml;llen im Rahmen des Art. 17 DSGVO die <strong>L&ouml;schung</strong> von Daten zu verlangen - insbesondere soweit die Daten f&uuml;r den vorgesehenen Zweck nicht mehr erforderlich sind bzw. unrechtm&auml;&szlig;ig verarbeitet werden, oder Sie Ihre Einwilligung gem&auml;&szlig; oben (c) widerrufen oder einen Widerspruch gem&auml;&szlig; oben (d) erkl&auml;rt haben; <br />f) unter bestimmten Voraussetzungen die <strong>Einschr&auml;nkung</strong> von Daten zu verlangen, soweit eine L&ouml;schung nicht m&ouml;glich bzw. die L&ouml;schpflicht streitig ist (Art. 18 DSGVO);<br />g) auf <strong>Daten&uuml;bertragbarkeit,</strong> d.h. Sie k&ouml;nnen Ihre Daten, die Sie uns bereitgestellt haben, in einem g&auml;ngigen maschinenlesbaren Format wie z.B. CSV erhalten und ggf. an andere &uuml;bermitteln (Art. 20 DSGVO;)<br />h) sich bei der zust&auml;ndigen <strong>Aufsichtsbeh&ouml;rde</strong> &uuml;ber die Datenverarbeitung zu <strong>beschweren</strong> (f&uuml;r Telekommunikationsvertr&auml;ge: Bundesbeauftragte f&uuml;r den Datenschutz und die Informationsfreiheit; im &Uuml;brigen: Landesbeauftragte f&uuml;r den Datenschutz und die Informationsfreiheit Nordrhein-Westfalen).</p><p><strong>8. An wen gibt die Telekom meine Daten weiter?</strong></p><p>An <strong>Auftragsverarbeiter</strong>, das sind Unternehmen, die wir im gesetzlich vorgesehenen Rahmen mit der Verarbeitung von Daten beauftragen, Art. 28 DSGVO (Dienstleister, Erf&uuml;llungsgehilfen). Die Telekom bleibt auch in dem Fall weiterhin f&uuml;r den Schutz Ihrer Daten verantwortlich. Wir beauftragen Unternehmen insbesondere in folgenden Bereichen: IT, Vertrieb, Marketing, Finanzen, Beratung, Kundenservice, Personalwesen, Logistik, Druck.<br /><strong>An Kooperationspartner,</strong> die in eigener Verantwortung Leistungen f&uuml;r Sie bzw. im Zusammenhang mit Ihrem Telekom-Vertrag erbringen. Dies ist der Fall, wenn Sie Leistungen solcher Partner bei uns beauftragen oder wenn Sie in die Einbindung des Partners einwilligen oder wenn wir den Partner aufgrund einer gesetzlichen Erlaubnis einbinden.<br /><strong>Aufgrund gesetzlicher Verpflichtung:</strong> In bestimmten F&auml;llen sind wir gesetzlich verpflichtet, bestimmte Daten an die anfragende staatliche Stelle zu &uuml;bermitteln.</p><p><strong>9. Wo werden meine Daten verarbeitet?</strong></p><p>Ihre Daten werden grunds&auml;tzlich in Deutschland und im europ&auml;ischen Ausland verarbeitet. <br />Findet eine Verarbeitung Ihrer Daten in Ausnahmef&auml;llen auch in L&auml;ndern au&szlig;erhalb der Europ&auml;ischen Union (also in sog. Drittstaaten) statt, geschieht dies, soweit Sie hierin ausdr&uuml;cklich eingewilligt haben oder es f&uuml;r unsere Leistungserbringung Ihnen gegen&uuml;ber erforderlich ist oder es gesetzlich vorgesehen ist (Art. 49 DSGVO). Dar&uuml;ber hinaus erfolgt eine Verarbeitung Ihrer Daten in Drittstaaten nur, soweit durch bestimmte Ma&szlig;nahmen sichergestellt ist, dass hierf&uuml;r ein angemessenes Datenschutzniveau besteht (z.B. Angemessenheitsbeschluss der EU-Kommission oder sog. geeignete Garantien, Art. 44ff. DSGVO).</p>",
            "moEngageLink": "https://www.moengage.com/gdpr/"
        },
        "faq": "https://www.monheim-pass.de/faq",
        "legalNotice": "https://monheim-pass.de/imprint",
        "termsAndConditions": "https://monheim-pass.de/terms"
    }
}
"""
    
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
    {  "content" : [ {    "branchList" : null,    "citizenServiceCategoryList" : null,    "cityColor" : "#0066ff",    "cityConfig" : {      "eventsCount" : 4,      "showBranches" : false,      "showCategories" : false,      "showDiscounts" : false,      "showFavouriteMarketplaces" : false,      "showFavouriteServices" : false,      "showHomeDiscounts" : false,      "showHomeOffers" : false,      "showHomeTips" : false,      "showMostUsedMarketplaces" : false,      "showMostUsedServices" : false,      "showNewMarketplaces" : false,      "showNewServices" : false,      "showOurMarketplaces" : true,      "showOurServices" : true,      "stickyNewsCount" : 4,      "yourEventsCount" : 2    },    "cityContentList" : null,    "cityId" : 1,    "cityName" : "Darmstadt", "imprintLink" : "https://imprint.com",   "cityPicture" : "/img/header_darmstadt2x.jpg",    "cityPreviewPicture" : "/img/header_prev_darmstadt.jpg",    "cityNightPicture" : "/img/header_prev_darmstadt.jpg",    "cityWeather" : {      "atmosphericPressure" : 1018,      "cityId" : 1,      "cityKey" : 2938912,      "cloudiness" : 40,      "description" : "Regenschauer",      "humidity" : 87,      "id" : 1,      "language" : "de",      "maximumTemperature" : 12.0,      "minimumTemperature" : 8.0,      "rainVolume" : 0,      "sunrise" : "1970-01-19 08:29:40",      "sunset" : "1970-01-19 08:30:17",      "temperature" : 10.0,      "visibility" : 10000,      "windDirection" : 200,      "windSpeed" : 4.6    },    "country" : "Germany",    "marketplacePicture" : "/img/header_marktplatz2x.jpg",    "municipalCoat" : "/img/WappenDarmstadt.png",    "postalCode" : 64283,    "postalCodeList" : null,    "servicePicture" : "/img/header_rathaus2x.jpg",    "stateName" : "Hessen"  }, {    "branchList" : null,    "citizenServiceCategoryList" : null,    "cityColor" : "#D50000",    "cityConfig" : {      "eventsCount" : 4,      "showBranches" : false,      "showCategories" : false,      "showDiscounts" : false,      "showFavouriteMarketplaces" : false,      "showFavouriteServices" : false,      "showHomeDiscounts" : false,      "showHomeOffers" : false,      "showHomeTips" : false,      "showMostUsedMarketplaces" : false,      "showMostUsedServices" : false,      "showNewMarketplaces" : false,      "showNewServices" : false,      "showOurMarketplaces" : true,      "showOurServices" : true,      "stickyNewsCount" : 4,      "yourEventsCount" : 2    },    "cityContentList" : null,    "cityId" : 2,    "cityName" : "Dortmund",    "cityPicture" : "/img/headerDortmund.png",    "cityPreviewPicture" : "/img/headerprevDortmund.jpg",    "cityNightPicture" : "/img/headerprevDortmund.jpg",    "cityWeather" : {      "atmosphericPressure" : 1018,      "cityId" : 1,      "cityKey" : 2938912,      "cloudiness" : 40,      "description" : "shower rain",      "humidity" : 87,      "id" : 2,      "language" : "en",      "maximumTemperature" : 12.0,      "minimumTemperature" : 8.0,      "rainVolume" : 0,      "sunrise" : "1970-01-19 08:29:40",      "sunset" : "1970-01-19 08:30:17",      "temperature" : 10.0,      "visibility" : 10000,      "windDirection" : 200,      "windSpeed" : 4.6    },    "country" : "Germany",    "marketplacePicture" : "/img/headerMarkplatzDortmund.jpg",    "municipalCoat" : "/img/municipalCoatDortmund.png",    "postalCode" : 44135,    "postalCodeList" : null,    "servicePicture" : "/img/headerBuergerServiceDortmund.jpg",    "stateName" : "Nordrhein-Westfalen"  }, {    "branchList" : null,    "citizenServiceCategoryList" : null,    "cityColor" : "#0098DB",    "cityConfig" : {      "eventsCount" : 4,      "showBranches" : false,      "showCategories" : false,      "showDiscounts" : false,      "showFavouriteMarketplaces" : false,      "showFavouriteServices" : false,      "showHomeDiscounts" : false,      "showHomeOffers" : false,      "showHomeTips" : false,      "showMostUsedMarketplaces" : false,      "showMostUsedServices" : false,      "showNewMarketplaces" : false,      "showNewServices" : false,      "showOurMarketplaces" : true,      "showOurServices" : true,      "stickyNewsCount" : 4,      "yourEventsCount" : 2    },    "cityContentList" : null,    "cityId" : 5,    "cityName" : "Monheim am Rhein",    "cityPicture" : "/img/headerMonheim.jpg",    "cityPreviewPicture" : "/img/headerprevMonheim.jpg",    "cityNightPicture" : "/img/headerprevMonheim.jpg",    "cityWeather" : {      "atmosphericPressure" : 1014,      "cityId" : 2,      "cityKey" : 2935517,      "cloudiness" : 75,      "description" : "shower rain",      "humidity" : 71,      "id" : 5,      "language" : "en",      "maximumTemperature" : 11.0,      "minimumTemperature" : 9.0,      "rainVolume" : 0,      "sunrise" : "1970-01-19 08:29:41",      "sunset" : "1970-01-19 08:30:18",      "temperature" : 10.0,      "visibility" : 10000,      "windDirection" : 210,      "windSpeed" : 8.2    },    "country" : "Germany",    "marketplacePicture" : "/img/header_Marktplatz_Monheim.jpg",    "municipalCoat" : "/img/logo_monheim3x.png",    "postalCode" : 40789,    "postalCodeList" : null,    "servicePicture" : "/img/headerBuergerserviceMonheim.jpg",    "stateName" : "Nordrhein-Westfalen"  } ]}
    """


}
