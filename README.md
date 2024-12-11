# Rapport om førpilot for emneplandelen av TEPS
Roar Bakken Stovner
2024-12-11

``` r
library(tidyverse)
```

## Rapport om TEPS Emneplaner, førpilot

Jeg har gjort så mye som mulig på 15 timer og endte med å bruke 16. Jeg
rakk å

1.  automatisk laste ned .html ut fra en liste med URLer
2.  automatisk hente ut data fra enkelte tags i htmlen
3.  fjerne html-tags og kun stå igjen med emneplanen
4.  kode fire variable med gpt
5.  gjort en manuell sammenlikning med de menneskelige koderne.

Jeg benyttet ca. 8 timer på del 1-3 og ca. 6 timer på 4-5 og ca. 2 timer
på denne rapporten. Det tar nå ca. 1 time å kode en ny variabel og
rekode den i henhold til kodeboka, men det kommer til å ta lenger tid
når alt skal valideres bedre.

Jeg betalte $1,17 for beregningstid hos OpenAI. Jeg anslår at det koster
3 kr å kode hvert emne på alle variablene hvis vi henter 10 variable fra
html-tags. Hvis det da er 50 kurs på 18 studiesteder blir total kostnad
2700 kr per år.

## Tags fra .html

Dataen jeg fikk fra .html ser slik ut. Jeg viser bare for ett fag.

``` r
emneplaner <- read_rds("data/emneplaner.Rds")
emneplaner |> slice(1) |> glimpse()
```

    Rows: 1
    Columns: 29
    $ nr                                           <dbl> 1
    $ navn                                         <chr> "Engelsk Emne 1"
    $ url                                          <chr> "https://student.oslomet.…
    $ emnekode                                     <chr> "M5GEN1100"
    $ aar                                          <dbl> 2024
    $ semester                                     <chr> "HØST"
    $ top_emnenavn                                 <chr> "English, Subject 1"
    $ top_studieprogram                            <chr> "Engelsk for trinn 5-10 i…
    $ studiepoeng                                  <chr> "15.0 stp."
    $ top_studiear                                 <chr> "2024/2025"
    $ top_timeplan                                 <chr> "HØST 2024"
    $ top_emnehistorikk                            <chr> "2017 / 2018 2018 / 2019 …
    $ top_emnekode                                 <chr> "M5GEN1100"
    $ emnenavn_norsk                               <chr> "Engelsk, emne 1"
    $ top_pensum                                   <chr> "HØST 2024"
    $ top_programplan                              <chr> NA
    $ sec_fagplan                                  <chr> "Engelsk (60 studiepoeng)…
    $ sec_forkunnskapskrav                         <chr> "Ingen."
    $ sec_laeringsutbytte                          <chr> "Etter fullført emne har …
    $ sec_innhold                                  <chr> "Å være engelsklærer:\n\n…
    $ sec_arbeids_og_undervisningsformer           <chr> "Se fagplanen."
    $ sec_arbeidskrav_og_obligatoriske_aktiviteter <chr> "Følgende arbeidskrav må …
    $ sec_vurdering_og_eksamen                     <chr> "Muntlig eksamen i gruppe…
    $ sec_hjelpemidler_ved_eksamen                 <chr> "Hver student kan ha med …
    $ sec_vurderingsuttrykk                        <chr> "Det benyttes en gradert …
    $ sec_sensorordning                            <chr> "Eksamen vurderes av to i…
    $ sec_innledning                               <chr> NA
    $ sec_anbefalte_forkunnskaper                  <chr> NA
    $ fulltekst                                    <chr> "M5GEN1100 Engelsk, emne …

Dataene vi kan høste rett fra html-fila kommer til å variere fra
institutsjon til institusjon, men trolig kan vi høste mange av
variablene rett fra html-tags uten å benytte en språkmodell.

Emneplanen vi henter ut blir seende slik ut:

``` r
emneplaner$fulltekst[1]
```

    [1] "M5GEN1100 Engelsk, emne 1 Emneplan\n\nEngelsk emnenavn\n\nEnglish, Subject 1\n\nStudieprogram\n\nEngelsk for trinn 5-10 i grunnskolen\n\nGrunnskolelærerutdanning for trinn 5-10\n\nOmfang\n\n15.0 stp.\n\nStudieår\n\n2024/2025\n\nPensum\n\nHØST 2024\n\nTimeplan\n\nHØST 2024\n\nEmnehistorikk\n\n2017 / 2018 2018 / 2019 2019 / 2020 2020 / 2021 2021 / 2022 2022 / 2023 2023 / 2024 2024 / 2025 2025 / 2026\n\n(function() { var select = document.getElementById('_no_oslomet_liferay_portlet_epn_EpnPortlet_v2_termSwitcher'); if (select) { } })();\n\nFagplan\n\nEngelsk (60 studiepoeng)\n\nFagplanen ble godkjent i studieutvalget 9. november 2016\n\nEndringer godkjent på fullmakt av leder i utdanningsutvalget 21. mars 2019\n\nRevisjon godkjent på fullmakt av prodekan 14. januar 2020\n\nRedaksjonell endring lagt inn 27. juni 2022\n\nGjeldende fra høstsemesteret 2022\n\nInnledning\n\nFagplanen bygger på forskrift om rammeplan for grunnskolelærerutdanningene for trinn 5-10, fastsatt av Kunnskapsdepartementet 7. juni 2016, nasjonale retningslinjer for grunnskolelærerutdanningen trinn 5-10 av 1. september 2016 og programplan for grunnskolelærerutdanning for trinn 5-10 ved OsloMet - storbyuniversitetet (OsloMet), godkjent av studieutvalget 16. november 2016.\n\nEngelsk har en unik stilling som verdensspråk og gir oss anledning til å delta i det globale fellesskapet. Vi trenger engelsk i utdanning, arbeidsliv og fritid og for å utvikle mellommenneskelig kommunikasjon og forståelse i en verden i stadig endring. Engelsklærerens hovedoppgave er derfor å utvikle både sin egen og elevenes språklige, kommunikative og interkulturelle kompetanse.\n\nEngelsk er et språk-, kultur-, og litteraturfag. Engelsklærere skal legge til rette for engelskundervisning i tråd med relevant forsknings- og utviklingsarbeid og gjeldende læreplan. Engelsklærerne må være trygge språkmodeller i klasserommet og ha innsikt i egne læringsstrategier. De må kunne lede læringsarbeidet i faget til beste for en mangfoldig elevgruppe, fra elevene starter på 5. trinn til de blir mer selvstendige språkbrukere mot slutten av barnetrinnet og på ungdomstrinnet. Dette innebærer at lærerstudentene gjennom engelskstudiet skal få innsikt i hvordan de grunnleggende ferdighetene er en integrert del av arbeidet med faget. Engelsklærerne må ha solid kunnskap om hvordan barn og unge tilegner seg språk og hvordan faget kan tilpasses aldersgruppen. De må også ha kunnskaper om det engelske språkets strukturer og om hvordan engelskspråklige tekster og andre kulturelle uttrykk kan benyttes for å fremme elevenes språkutvikling, nytenkning og evne til kritisk refleksjon.\n\nMålgruppe\n\nStudenter som er tatt opp til femårig grunnskolelærerutdanning for trinn 5-10.\n\nOpptakskrav\n\nFaget er tilgjengelig som valgfag for aktive studenter ved grunnskolelærerutdanningen, i tråd med programplanen.\n\nLæringsutbytte\n\nLæringsutbyttet er nærmere beskrevet i emneplanene.\n\nFagets innhold og oppbygging\n\nEngelsk (60 studiepoeng) er bygget opp av fire emner à 15 studiepoeng. I grunnskolelærerutdanningen trinn 5-10 må studenten ta 60 studiepoeng for at faget skal godkjennes som del av utdanningen. Dette er begrunnet i at 60 studiepoeng er minste kompetansegivende enhet for 8.-10. trinn. Utdanningen skal forberede studenten til å være lærer for alle trinn fra 5. til 10. trinn.\n\nFor studenter som tar faget i 1. og 2. studieår\n\nEngelsk for 5.-10. trinn tilbys organisert som 45 studiepoeng i første studieår og 15 studiepoeng i andre studieår, til sammen 60 studiepoeng. Undervisning i emne 1, 2 og 3 gis i første studieår, og undervisning i emne 4 gis i første semester av andre studieår.\n\nHøst: M5GEN1100 Engelsk, emne 1, 15 studiepoengHøst og vår: M5GEN1200 Engelsk, emne 2, 15 studiepoengVår: M5GEN1300 Engelsk, emne 3, 15 studiepoengHøst: M5GEN2100 Engelsk, emne 4, 15 studiepoeng\n\nFor studenter som tar faget i 3. studieår\n\nEngelsk for 5.-10 trinn tilbys også organisert som 60 studiepoeng over ett studieår. Undervisningen i faget er organisert i fire emner à 15 studiepoeng. Undervisningen foregår i all hovedsak sammen med studentene som tar faget i 1. og 2. studieår (emne 4 arrangeres separat).\n\nHøst: M5GEN1100 Engelsk, emne 1, 15 studiepoengHøst og vår: M5GEN1200 Engelsk, emne 2, 15 studiepoengVår: M5GEN1300 Engelsk, emne 3, 15 studiepoengHøst og vår: M5GEN3100 Engelsk, emne 4, 15 studiepoeng (gjelder fra og med termin 2022 høst)\n\nEmne 1 og 2 omfatter engelskundervisning for mellom- og ungdomstrinnet, med vekt på det som kjennetegner elevene i denne aldersgruppen og deres språkutvikling i engelsk. Emnet gir en innføring i engelskdidaktikk, språklige tema og et variert utvalg av litteratur, både skjønnlitteratur og sakprosa, og andre kulturelle uttrykk fra den engelskspråklige verden. Utviklingen av egen språkferdighet og litteratur- og tekstkompetanse står sentralt. I tillegg dreier disse emnene seg om varierte aktiviteter og metoder for engelskopplæringen i grunnskolen.\n\nEmne 3 og 4 bygger på de to første emnene og gir dypere innsikt i engelskdidaktiske spørsmål i opplæringen av elever på slutten av barneskolen (5.-7. trinn) og på ungdomstrinnet. Emne 3 og 4 omfatter videreutvikling av studentens egen språkferdighet og tekstkompetanse. Studentene vil videreutvikle sine kunnskaper om språkets strukturer, om litteratur og andre kulturelle uttrykk og om samfunnsspørsmål i engelsktalende land. Emnene gir økt erfaring i bruk av inspirerende og læringsfremmende aktiviteter og arbeidsmåter og økt innsikt i valg og bruk av tekster og andre læringsressurser.\n\nFagovergripende tema med relevans for engelskfaget i grunnskolelærerutdanningen for trinn 5-10\n\nKlasseledelse og lærerrollen sett fra faget\n\nKlasseledelse i engelskfaget betyr å sikre alle elever de beste muligheter til å lære å forstå og bruke det engelske språket. Læreren må kunne skape gode arbeidsforhold og et inkluderende læringsmiljø der elevene trygt får bruke hele seg og utvikle sin kommunikative kompetanse på engelsk sammen med andre.\n\nTilpasset opplæring\n\nGjennom studiet utvikler studentene sin innsikt i hva det innebærer å gi tilpasset opplæring i engelskfaget. Studentene bevisstgjøres om hvilke didaktiske valg de kan foreta i engelskopplæringen ut fra de enkelte elevenes kognitive og sosiale utviklingsnivå og deres språklige og kulturelle bakgrunn.\n\nVurdering - kartleggingsverktøy og oppfølging\n\nStudentene arbeider med vurdering for, av og som læring gjennom møtet med ulike typer elevtekster og får anledning til å øve seg på å gi læringsfremmende tilbakemeldinger med og uten karakter. De får kjennskap til formativ bruk av kartleggingsverktøy. Vurderingsarbeidet knyttes også opp mot studentenes egne praksiserfaringer.\n\nGrunnleggende ferdigheter\n\nDet å kunne lytte og forstå, snakke, lese og skrive er sentrale ferdigheter i språkfaget engelsk. Sammen med digital kompetanse og det å kunne regne i engelsk er de også grunnleggende for elevenes læring og utvikling. Studentene bygger sin egen kompetanse i og om de grunnleggende ferdighetene med relevans for engelskopplæringen i skolen.\n\nDigital kompetanse\n\nDigital kompetanse er i engelsk rettet mot bruk som student, som framtidig lærer og i elevenes læringsarbeid. Det vil bli brukt relevante digitale medier i alle fagets emner. Det legges vekt på å utvikle studentenes profesjonsfaglig digitale kompetanse i og med bruk av digitale verktøy for alle deler av læringsarbeidet. Som framtidig lærer må studenten være i stand til å benytte digitale verktøy i planlegging, gjennomføring og evaluering av læringsarbeidet. Dette innebærer også å kunne velge og vurdere relevante digitale verktøy i elevenes læringsarbeid. Studentenes skal ha et kritisk og reflektert forhold til hvordan de nye digitale mediene kan brukes på en god og læringsfremmende måte i klasserommet. Kildekritikk, opphavsrett og personvern er sentrale områder i digitale sammenhenger som også inngår i engelskfaget.\n\nLærerarbeid i det mangfoldige klasserommet\n\nI engelskstudiet får studentene forskningsbasert innsikt i hvordan elever lærer et andre- og tredjespråk og hva som kjennetegner undervisning i et mangfoldig klasserom fra et språklig, kulturelt, kjønns- og likestillingsperspektiv. Gjennom sine praksiserfaringer blir studentene mer bevisst elevers individuelle særtrekk, deres språklige og kulturelle bakgrunn og får anledning til å utvikle sitt engelskdidaktiske repertoar slik at de kan gi tilpasset opplæring til beste for alle elevene. Studentene skal tilegne seg kunnskap og ferdigheter som gjør de i stand til å møte og forstå ulikhet og bruke mangfoldet som en ressurs i engelskundervisningen.\n\nYrkesretting\n\nEngelskopplæring vil ikke være helt det samme for elever som velger å utdanne seg til et yrkesfag som for elever som velger studieforberedende retning i videregående skole. Engelsk trinn 5-10 skal bevisstgjøre studentene på elevenes ulike behov når det gjelder framtidig yrkesvalg. Dette har konsekvenser for didaktiske valg av mål, innhold og arbeidsmåter i opplæringen.\n\nOvergangen mellom trinnene når det gjelder engelskfaget\n\nStudiet tar sikte på å gjøre studentene i stand til å ta de grep innenfor engelskfaget som kan bidra til å lette elevenes overgang fra barnetrinn til ungdomstrinn og videre til videregående opplæring. Sentralt i dette arbeidet står kunnskap om elevenes utvikling i vid forstand, faglig progresjon og læringsfremmende vurdering.\n\nEstetiske arbeidsmåter\n\nEstetiske arbeidsmåter i engelskfaget kan fremme affektive mål som motivasjon, kreativitet og læreglede. Ved å legge vekt på innhold, arbeidsmåter og vurdering som involverer alle sanser i tillegg til rent kognitive prosesser, får studentene erfaring med ulike deler av faget. Estetiske arbeidsmåter kan være rollespill, der deltakerne får utforske andre perspektiver enn sine egne, og aktiviteter som gir rom for språkets lydlige og visuelle uttrykksformer.\n\nInternasjonale perspektiver\n\nEn internasjonal orientering er sentral i engelskfaget, siden verdensspråket engelsk brukes som kontaktspråk for mennesker fra ulike land og kulturer. Faget henter det meste av sitt lærestoff fra ulike deler av den engelskspråklige verden, spesielt når det gjelder forskning, kulturkunnskap og et variert utvalg tekster. I løpet av studiet legges det til rette for et studieopphold ved en partnerskapsinstitusjon i et engelskspråklig land.\n\nPraksistilknytning\n\nTilknytningen til praksisfeltet står sentralt i engelskfaget både når det gjelder fagdidaktisk innhold i studiet og i praksisperiodene ute i skolen. Studentene får der anledning til å prøve ut rollen som engelsklærer og som språkmodell. De får arbeide med valg og formidling av lærestoff, med å tilpasse opplæringen til mangfoldige elevgrupper og vurdere elevenes læring.\n\nForskningsforankring\n\nUndervisningen i engelskfaget er forsknings- og utviklingsbasert. Pensumlitteraturen gir studenter basiskunnskap i fag og fagdidaktikk med innhold som fremmer kritisk tenkning. Studentene får anledning til å reflektere over og begrunne sitt praktiske lærerarbeid ut fra relevant teori. De blir kjent med vitenskapelige tenkemåter, metodisk framstilling og akademisk skriving på engelsk.\n\nPsykososialt læringsmiljø\n\nI engelskstudiet blir studentene del av et aksepterende læringsmiljø preget av høye forventninger, der de trygt kan utvikle seg i det tempoet som er naturlig for den enkelte. Dette kommer til uttrykk i en dialogisk tilnærming til deltakelse og i tilbakemeldinger på studieoppgaver. I praksisperiodene ute i skolen får studentene anledning til selv å skape et trygt og godt læringsmiljø for elevene.\n\nSamiske forhold og rettigheter\n\nI engelskstudiet er urfolk i engelskspråklige land et viktig tema. Studentene arbeider med dette temaet i tilknytning til noen av pensumtekstene. I den forbindelse er det naturlig å trekke forbindelseslinjer til vårt eget urfolk, samene, gjennom sammenlikning av språk, rettigheter, kulturer og levevilkår.\n\nBærekraftig utvikling\n\nKunnskap og bevissthet om hva som kjennetegner en bærekraftig utvikling har sin plass i engelskstudiet, blant annet som tema i flere av de litterære tekstene på pensum. I tillegg til kunnskapsformidlingen vil oppøvingen av studentenes evne til å stille kritiske spørsmål, analysere, se sammenhenger og identifisere utfordringer være en viktig del av utdanning til bærekraftig utvikling.\n\nPraksisopplæring\n\nPraksisopplæring er nærmere beskrevet i programplanen.\n\nSkikkethetsvurdering\n\nLærerutdanningsinstitusjoner har ansvar for å vurdere om studenter er skikket for læreryrket. Løpende skikkethetsvurdering foregår gjennom hele studiet og inngår i en helhetsvurdering av studentens faglige og personlige forutsetninger for å kunne fungere som lærer. En student som utgjør en mulig fare for elevers liv, fysiske og psykiske helse, rettigheter og sikkerhet, er ikke skikket for yrket. Studenter som viser liten evne til å mestre læreryrket, skal så tidlig som mulig i utdanningen få melding om dette. De skal få råd og veiledning for å gjøre dem i stand til å oppfylle kravene om lærerskikkethet eller få råd om å avslutte utdanningen. Beslutninger om skikkethet kan fattes gjennom hele studiet.\n\nSe universitetets nettsted for mer informasjon om skikkethetsvurdering.\n\nFagets arbeids- og undervisningsformer\n\nEngelsk er et språk som studenter i grunnutdanningen og elever i skolen møter og arbeider med i tillegg til skolespråket norsk. Studentene utvikler sin evne til å se flerspråklighet som en ressurs i arbeidet med engelsk. Et rikt og variert utvalg av tekster både til personlig og faglig vekst og til bruk i undervisning for både gutter og jenter på 5.-10. trinn er en integrert del av studiet. Flerkulturelle perspektiver i engelskfaget tematiseres i arbeidet med selve språket som uttrykk for kultur, gjennom arbeidet med tekster fra ulike land og perioder og ikke minst fokus på språkbruk tilpasset kontekst.\n\nArbeidsspråket i studiet er engelsk, både muntlig og skriftlig. Undervisning, arbeidskrav og eksamen foregår og fullføres på engelsk. Studiearbeidet består av varierte arbeidsformer. Noe av lærestoffet vil bli formidlet gjennom forelesninger; annet vil tas opp i ulike former for verksteder (workshops) og seminarer ledet av faglærere eller studenter. I tillegg vil fagstoff være tilgjengelig på høgskolens læringsplattform. Det forventes at studentene tilegner seg en del av pensumlitteraturen på egen hånd.\n\nI tillegg til forelesninger og profesjonsfaglige verksteder vil studiearbeidet være knyttet til innlevering av arbeidskrav i form av ulike typer tekster. Studentene skriver, gjør muntlige opptak eller lager multimodale tekster som svar på relevante oppgaver i forkant som forberedelse til eller i etterkant som konsolidering av ulike undervisningstemaer. Antall arbeidskrav står i avsnittet \"Arbeidskrav\" under hvert emne. Det blir gitt krav til omfang på skriftlige tekster og antall minutters tale når det gjelder muntlige innlegg. Likeledes blir det gitt kriterier for godkjenning av disse som arbeidskrav.\n\nArbeidskrav\n\nArbeidskrav skal være levert/utført innen fastsatt(e) frist(er). Gyldig fravær dokumentert med for eksempel sykemelding, gir ikke fritak for å innfri arbeidskrav. Studenter som på grunn av sykdom eller annen dokumentert gyldig årsak ikke leverer/utfører arbeidskrav innen fristen, kan få forlenget frist. Ny frist for å innfri arbeidskrav avtales i hvert enkelt tilfelle med den fagansvarlige læreren.\n\nArbeidskrav vurderes til \"Godkjent\" eller \"Ikke godkjent\". Studenter som leverer/utfører arbeidskrav innen fristen, men som får vurderingen \"Ikke godkjent\", har anledning til to nye innleveringer/utførelser. Studenten må da selv avtale ny innlevering av det aktuelle arbeidskravet med faglærer. Studenter som ikke leverer/utfører arbeidskrav innen fristen og som ikke har dokumentert gyldig årsak, får ingen nye forsøk.\n\nI programplanen er de fagovergripende temaene på de ulike studieårene og semestrene beskrevet. I tilknytning til disse kan det være krav til tilstedeværelse og/eller andre arbeidskrav.\n\nFaglig aktivitet med krav om deltakelse\n\nLæringsprosessen i engelskstudiet forutsetter samhandling med andre studenter og faglærere om sentrale utfordringer i faget, vurdering av undervisning og utvikling av muntlige ferdigheter. Denne delen av en lærers handlingskompetanse kan ikke tilegnes kun ved lesing, men må opparbeides i reell dialog og ved tilstedeværelse i undervisningen. Alle fire emner i engelskfaget har derfor følgende krav om deltakelse:\n\nDeltakelse i minimum 80 prosent av undervisningen. Studenter som ikke oppfyller kravet om deltakelse, må levere kompensasjonsoppgaver om sentrale profesjonsrelevante tema.\n\nManglende deltakelse i faglige aktiviteter som er nevnt over, medfører at studenten ikke får avlegge eksamen i det emnet kravet om deltakelse er knyttet til. Sykdom fritar ikke for kravet om deltakelse.\n\nNærmere informasjon om arbeidskrav finnes i den enkelte emneplan.\n\nVurderings-/eksamensformer\n\nSe emneplanene under punktet Vurderings-/eksamensformer.\n\nVurderingskriterier for emne 1, 2 og 3\n\nA: Fremragende. Viser fremragende kunnskaper og ferdigheter innenfor kompetanseområdene i faget. Viser fremragende evne til refleksjon og selvstendig tenkning i forhold til læringsmål, fagets egenart og tilrettelegging av et godt læringsmiljø.\n\nB: Meget god. Viser meget gode kunnskaper og ferdigheter innenfor kompetanseområdene i faget. Viser meget god evne til refleksjon og selvstendig tenkning i forhold til læringsmål, fagets egenart og tilrettelegging av et godt læringsmiljø.\n\nC: God. Viser gode kunnskaper og ferdigheter innenfor kompetanseområdene i faget. Viser god evne til refleksjon og selvstendig tenkning i forhold til læringsmål, fagets egenart og tilrettelegging av et godt læringsmiljø.\n\nD: Nokså god. Viser begrensede kunnskaper og ferdigheter innenfor kompetanseområdene i faget. Viser begrenset evne til refleksjon og selvstendig tenkning i forhold til læringsmål, fagets egenart og tilrettelegging av et godt læringsmiljø.\n\nE: Tilstrekkelig. Tilfredsstiller minimumskravene til kunnskaper og ferdigheter innenfor kompetanseområdene i faget. Viser noe evne til refleksjon og selvstendig tenkning i forhold til læringsmål, fagets egenart og tilrettelegging av et godt læringsmiljø.\n\nF: Ikke bestått. Har utilstrekkelig kunnskaper og ferdigheter innenfor kompetanseområdene i faget. Viser dårlig evne til refleksjon og selvstendig tenkning i forhold til læringsmål, fagets egenart og tilrettelegging av et godt læringsmiljø.\n\nVurderingskriterier for emne 4\n\nA: Fremragende. Fremragende prestasjon som klart utmerker seg. Kandidaten viser svært god vurderingsevne, stor faglig oversikt og stor grad av selvstendighet.\n\nB: Meget god. Meget god prestasjon som viser meget god vurderingsevne og selvstendighet.\n\nC: God. Solid prestasjon som er tilfredsstillende på de fleste områder. Kandidaten viser god vurderingsevne og selvstendighet på de fleste områder.\n\nD: Nokså god. En akseptabel prestasjon med noen vesentlige mangler. Kandidaten viser en viss grad av vurderingsevne og selvstendighet.\n\nE: Tilstrekkelig. Prestasjon som tilfredsstiller minimumskrav, men ikke mer.\n\nF: Ikke bestått. Prestasjon som ikke tilfredsstiller minimumskravene.\n\nUtfyllende kriterier framgår av retningslinjer som gjøres tilgjengelig ved starten av emnet.\n\nRettigheter og plikter ved eksamen\n\nStudentens rettigheter og plikter framgår av forskrift om studier og eksamen ved OsloMet. Forskriften beskriver blant annet vilkår for ny/utsatt eksamen, klageadgang og hva som regnes som fusk ved eksamen. Studenten er selv ansvarlig for å melde seg opp til eventuell ny/utsatt eksamen.\n\nForkunnskapskrav\n\nIngen.\n\nLæringsutbytte\n\nEtter fullført emne har studenten følgende læringsutbytte definert som kunnskap, ferdigheter og generell kompetanse:\n\nKunnskap\n\nStudenten\n\nhar kunnskap om hvordan barn og unge lærer språk\n\nhar kunnskap om flerspråklighet som ressurs i klasserommet\n\nhar kunnskap om læreplanverket, nasjonale prøver og læremidler for engelskfaget\n\nhar kunnskap om tilegnelse av ordforråd og om strukturer i engelsk fra lyd- til tekstnivå\n\nkjenner forsknings- og utviklingsarbeid som er relevant for engelskfaget på trinn 5-10\n\nFerdigheter\n\nStudenten\n\nkan bruke engelsk muntlig og skriftlig, sikkert og selvstendig\n\nkan bruke underveis- og sluttvurdering for å veilede elever i engelskopplæringen\n\nkan planlegge og lede varierte og differensierte læringsaktiviteter, også digitale, som fremmer dybdelæring og utvikling av de grunnleggende ferdighetene\n\nGenerell kompetanse\n\nStudenten\n\nkan formidle relevant fagstoff og kommunisere på engelsk på en måte som er tilpasset elever på trinn 5-10\n\nkan reflektere over egen læring og undervisningspraksis i lys av etiske grunnverdier og skolens ansvar for barn og unges personlige vekst\n\nkan arbeide selvstendig og sammen med andre for å tilrettelegge for elevers læring og utvikling\n\nkan vedlikeholde og utvikle sin egen språklige og didaktiske kompetanse\n\nInnhold\n\nÅ være engelsklærer:\n\nSpråklæringsteorier, strategier og metoder\n\nFlerspråklighet som ressurs i klasserommet\n\nEngelsk i Norge og verden\n\nLæreplan og læremidler, inkludert digitale læremidler\n\nInnføring i grunnleggende ferdigheter i engelskfaget\n\nInnføring i engelsk språk og struktur\n\nInnføring i tekst og kultur\n\nVurdering av og for læring\n\nEngelsklæreren som språkmodell\n\nArbeids- og undervisningsformer\n\nSe fagplanen.\n\nArbeidskrav og obligatoriske aktiviteter\n\nFølgende arbeidskrav må være godkjent før eksamen i emnet kan avlegges:\n\nIndividuell skriftlig oppgave, tekst på 900 ord +/- 10 %. Formålet med oppgaven er drøfting av sentrale teoretiske begreper innen språklæring og -undervisning, utvikling av studentenes egne skriveferdigheter og arbeid med digital tekstbehandling.\n\nOppgave i par i form av lydfil på 2-3 minutter fra hver student og skriftlig tekst på 500 ord +/- 10% fra hver student. Oppgaven fokuserer på arbeid med læreplanen og læremidler og læreren som språkmodell, samt utvikling av studentenes digitale kompetanse.\n\nKrav om deltakelse i undervisningen (som beskrevet under «Arbeidskrav» i den innledende delen av fagplanen).\n\nVurdering og eksamen\n\nMuntlig eksamen i grupper på tre studenter (eller par hvis nødvendig ut fra studenttall), med varighet på 15 minutter til presentasjon av en gitt oppgave og 10 minutter til spørsmål per gruppe fra sensorene. Det gis individuell karakter. Eksamensspråket er engelsk.\n\nNy/utsatt eksamen arrangeres som ved ordinær eksamen. Av praktiske hensyn vil gruppeeksamen kunne gjennomføres som individuell eksamen ved ny/utsatt eksamen.\n\nHjelpemidler ved eksamen\n\nHver student kan ha med seg et A4-ark med notater.\n\nVurderingsuttrykk\n\nDet benyttes en gradert karakterskala fra A til E for bestått og F for ikke bestått eksamen\n\nSensorordning\n\nEksamen vurderes av to interne sensorer. En tilsynssensor er tilknyttet emnet, i henhold til retningslinjer for oppnevning og bruk av sensorer ved OsloMet."

Dette er flott for en maskin, for tegnene “\n” betyr newline, så en
maskin vil lese dette som en lang tekst med fin avsnittstruktur.

# Kode variable med GPT

Jeg har kodet fire variable. Jeg valgte variable ut fra kriteriet
“stigende kompleksitet”. Variablene er “forkunnskap” (ja/nei),
“eksamensform” (8 forskjellige ja/nei), “arbeidskrav” (7 forskjellige ja
nei) og “arbeidskravantall” (et heltall).

## Forkunnskap

Her er dataene for den menneskelige kodingen av ‘forkunnskapskrav’ pluss
tre kall til språkmodellen.

``` r
forkunnskap <- read_rds("data/forkunnskap.Rds") |> arrange(emnekode)
begrunnelse <- forkunnskap |> filter(!is.na(begrunnelse)) |> select(emnekode,begrunnelse)

forkunnskap |> select(!begrunnelse) |> pivot_wider(names_from = koder, values_from = Forkunnskapskrav) |> select(-human3) |> left_join(begrunnelse, by = "emnekode") |> tinytable::tt()
```

<table style="width:99%;">
<colgroup>
<col style="width: 3%" />
<col style="width: 2%" />
<col style="width: 2%" />
<col style="width: 7%" />
<col style="width: 5%" />
<col style="width: 7%" />
<col style="width: 69%" />
</colgroup>
<thead>
<tr class="header">
<th>emnekode</th>
<th>human1</th>
<th>human2</th>
<th>gpt-4o-mini-2024-07-18</th>
<th>gpt-4o-2024-08-06</th>
<th>gpt-4o-2024-08-06-CoT</th>
<th>begrunnelse</th>
</tr>
</thead>
<tbody>
<tr class="odd">
<td>M5GEN1100</td>
<td>1</td>
<td>1</td>
<td>1</td>
<td>1</td>
<td>1</td>
<td>Ingen forkunnskapskrav.</td>
</tr>
<tr class="even">
<td>M5GEN2100</td>
<td>1</td>
<td>1</td>
<td>2</td>
<td>2</td>
<td>2</td>
<td>Ingen.</td>
</tr>
<tr class="odd">
<td>M5GMT2100</td>
<td>1</td>
<td>1</td>
<td>2</td>
<td>2</td>
<td>2</td>
<td>Ingen.</td>
</tr>
<tr class="even">
<td>M5GNA2100</td>
<td>1</td>
<td>1</td>
<td>1</td>
<td>1</td>
<td>1</td>
<td>Ingen forkunnskapskrav.</td>
</tr>
<tr class="odd">
<td>M5GNA2200</td>
<td>1</td>
<td>1</td>
<td>2</td>
<td>2</td>
<td>2</td>
<td>Ingen forkunnskapskrav.</td>
</tr>
<tr class="even">
<td>M5GNA3100</td>
<td>2</td>
<td>2</td>
<td>2</td>
<td>2</td>
<td>2</td>
<td>Se under Opptakskrav i fagplanen.</td>
</tr>
<tr class="odd">
<td>M5GP1000</td>
<td>1</td>
<td>1</td>
<td>2</td>
<td>2</td>
<td>1</td>
<td>Forkunnskapskrav er ikke nevnt eksplisitt.</td>
</tr>
<tr class="even">
<td>M5GPE1100</td>
<td>1</td>
<td>1</td>
<td>1</td>
<td>1</td>
<td>1</td>
<td>Ingen forkunnskapskrav.</td>
</tr>
<tr class="odd">
<td>M5GPE2100</td>
<td>1</td>
<td>1</td>
<td>2</td>
<td>2</td>
<td>2</td>
<td>Ingen.</td>
</tr>
<tr class="even">
<td>M5GRL2100</td>
<td>1</td>
<td>1</td>
<td>2</td>
<td>1</td>
<td>1</td>
<td>Ingen forkunnskapskrav.</td>
</tr>
<tr class="odd">
<td>M5GRL2200</td>
<td>1</td>
<td>1</td>
<td>2</td>
<td>2</td>
<td>2</td>
<td>Ingen forkunnskapskrav.</td>
</tr>
<tr class="even">
<td>MGKH2100</td>
<td>1</td>
<td>1</td>
<td>2</td>
<td>1</td>
<td>2</td>
<td>Ingen forkunnskapskrav.</td>
</tr>
<tr class="odd">
<td>MGKH3100</td>
<td>2</td>
<td>1</td>
<td>2</td>
<td>2</td>
<td>2</td>
<td>Forkunnskapskravene er at interne søkere kan få opptak uten å ha
fullført Kunst og håndverk 1, mens eksterne søkere må ha bestått
lærerutdanning som kvalifiserer for arbeid i skolen og fullført Kunst og
håndverk 1 eller tilsvarende.</td>
</tr>
<tr class="even">
<td>MGKP4101</td>
<td>NA</td>
<td>2</td>
<td>2</td>
<td>2</td>
<td>2</td>
<td>Opptak til Kroppsøvingsdidaktikk krever fullført 60 studiepoeng
kroppsøving på syklus 1.</td>
</tr>
<tr class="odd">
<td>MGLU1501</td>
<td>NA</td>
<td>NA</td>
<td>NA</td>
<td>NA</td>
<td>NA</td>
<td>NA</td>
</tr>
<tr class="even">
<td>MGLU3513</td>
<td>NA</td>
<td>NA</td>
<td>NA</td>
<td>NA</td>
<td>NA</td>
<td>NA</td>
</tr>
<tr class="odd">
<td>MGLU3522</td>
<td>NA</td>
<td>NA</td>
<td>NA</td>
<td>NA</td>
<td>NA</td>
<td>NA</td>
</tr>
<tr class="even">
<td>MGLU4213</td>
<td>NA</td>
<td>NA</td>
<td>NA</td>
<td>NA</td>
<td>NA</td>
<td>NA</td>
</tr>
<tr class="odd">
<td>MGLU5203</td>
<td>NA</td>
<td>NA</td>
<td>NA</td>
<td>NA</td>
<td>NA</td>
<td>NA</td>
</tr>
<tr class="even">
<td>MGMO5900</td>
<td>NA</td>
<td>2</td>
<td>2</td>
<td>2</td>
<td>2</td>
<td>For å kunne levere masteroppgaven til sensur må FOU-oppgaven og
emnet Vitenskapsteori og metode være bestått.</td>
</tr>
<tr class="odd">
<td>MGMU4200</td>
<td>NA</td>
<td>2</td>
<td>2</td>
<td>2</td>
<td>1</td>
<td>Se fagplanen.</td>
</tr>
<tr class="even">
<td>MGNO4200</td>
<td>NA</td>
<td>2</td>
<td>2</td>
<td>2</td>
<td>1</td>
<td>Se fagplanen.</td>
</tr>
<tr class="odd">
<td>MGPE3300</td>
<td>1</td>
<td>1</td>
<td>1</td>
<td>2</td>
<td>1</td>
<td>Ingen forkunnskapskrav.</td>
</tr>
<tr class="even">
<td>MGSF5100</td>
<td>NA</td>
<td>2</td>
<td>2</td>
<td>2</td>
<td>2</td>
<td>Se fagplanen.</td>
</tr>
<tr class="odd">
<td>MGVM4100</td>
<td>NA</td>
<td>1</td>
<td>2</td>
<td>2</td>
<td>2</td>
<td>Ingen forkunnskapskrav.</td>
</tr>
<tr class="even">
<td>PPU4602</td>
<td>NA</td>
<td>NA</td>
<td>NA</td>
<td>NA</td>
<td>NA</td>
<td>NA</td>
</tr>
</tbody>
</table>

Kolonnenavnet angir språkmodellen, henholdsvis den billigere og raskere
gpt-4o-mini og gpt-4o. Den varianter med gpt-4o som slutter på “CoT”
benytter *Chain of thought reasoning* (CoT). Dette er at man først ber
modellen om å resonnere og begrunne og deretter ber om svar.
Begrunnelsen er i en egen kolonne. Vi ser at modellen synes det er
uklart om “Ingen” og “Ingen forkunnskapskrav” er å eksplisitt nevne
forkunnskapskrav eller ikke. Vi bør i fremtiden endre svaralternativene
til

1.  Ingen forkunnskapskrav
2.  Ingen forkunnskapskrav nevnt.
3.  Forkunnskapskrav nevnt.

Bortsett fra dette ser det ut til at språkmodellene finner
forkunnskapskravene og med riktig begrunnelse.

## Eksamensform

Her er dataene for eksamensform. Siden det er så mange variabler må man
lese denne tabellen annerledes. Hver fjerde rad er ett emne.

``` r
eksamensform <- read_rds("data/eksamensform.Rds")

eksamensform |> select(-gpt_model,-gpt_response) |> relocate(koder, .after = emnekode) |> tinytable::tt()
```

<table style="width:97%;">
<colgroup>
<col style="width: 4%" />
<col style="width: 8%" />
<col style="width: 6%" />
<col style="width: 6%" />
<col style="width: 6%" />
<col style="width: 6%" />
<col style="width: 6%" />
<col style="width: 6%" />
<col style="width: 6%" />
<col style="width: 6%" />
<col style="width: 35%" />
</colgroup>
<thead>
<tr class="header">
<th>emnekode</th>
<th>koder</th>
<th>Eksamensform.1</th>
<th>Eksamensform.2</th>
<th>Eksamensform.3</th>
<th>Eksamensform.4</th>
<th>Eksamensform.5</th>
<th>Eksamensform.6</th>
<th>Eksamensform.7</th>
<th>Eksamensform.8</th>
<th>Eksamensform_andre</th>
</tr>
</thead>
<tbody>
<tr class="odd">
<td>M5GEN1100</td>
<td>gpt-4o-mini-2024-07-18</td>
<td>0</td>
<td>1</td>
<td>0</td>
<td>1</td>
<td>0</td>
<td>0</td>
<td>0</td>
<td>0</td>
<td>NA</td>
</tr>
<tr class="even">
<td>M5GEN1100</td>
<td>gpt-4o-2024-08-06</td>
<td>0</td>
<td>0</td>
<td>0</td>
<td>1</td>
<td>0</td>
<td>0</td>
<td>0</td>
<td>0</td>
<td>NA</td>
</tr>
<tr class="odd">
<td>M5GEN1100</td>
<td>human1</td>
<td>0</td>
<td>0</td>
<td>0</td>
<td>1</td>
<td>0</td>
<td>0</td>
<td>0</td>
<td>0</td>
<td>NA</td>
</tr>
<tr class="even">
<td>M5GEN1100</td>
<td>human2</td>
<td>0</td>
<td>0</td>
<td>0</td>
<td>1</td>
<td>0</td>
<td>0</td>
<td>0</td>
<td>0</td>
<td>NA</td>
</tr>
<tr class="odd">
<td>M5GEN2100</td>
<td>gpt-4o-mini-2024-07-18</td>
<td>0</td>
<td>1</td>
<td>1</td>
<td>1</td>
<td>0</td>
<td>0</td>
<td>0</td>
<td>0</td>
<td>NA</td>
</tr>
<tr class="even">
<td>M5GEN2100</td>
<td>gpt-4o-2024-08-06</td>
<td>0</td>
<td>1</td>
<td>0</td>
<td>0</td>
<td>0</td>
<td>0</td>
<td>0</td>
<td>0</td>
<td>NA</td>
</tr>
<tr class="odd">
<td>M5GEN2100</td>
<td>human1</td>
<td>0</td>
<td>1</td>
<td>0</td>
<td>0</td>
<td>0</td>
<td>0</td>
<td>0</td>
<td>0</td>
<td>NA</td>
</tr>
<tr class="even">
<td>M5GEN2100</td>
<td>human2</td>
<td>0</td>
<td>1</td>
<td>0</td>
<td>0</td>
<td>0</td>
<td>0</td>
<td>0</td>
<td>0</td>
<td>NA</td>
</tr>
<tr class="odd">
<td>M5GMT2100</td>
<td>gpt-4o-mini-2024-07-18</td>
<td>0</td>
<td>1</td>
<td>0</td>
<td>1</td>
<td>0</td>
<td>0</td>
<td>0</td>
<td>0</td>
<td>NA</td>
</tr>
<tr class="even">
<td>M5GMT2100</td>
<td>gpt-4o-2024-08-06</td>
<td>0</td>
<td>1</td>
<td>0</td>
<td>1</td>
<td>0</td>
<td>0</td>
<td>0</td>
<td>0</td>
<td>NA</td>
</tr>
<tr class="odd">
<td>M5GMT2100</td>
<td>human2</td>
<td>0</td>
<td>1</td>
<td>0</td>
<td>1</td>
<td>0</td>
<td>0</td>
<td>0</td>
<td>0</td>
<td>NA</td>
</tr>
<tr class="even">
<td>M5GMT2100</td>
<td>human1</td>
<td>0</td>
<td>1</td>
<td>0</td>
<td>1</td>
<td>0</td>
<td>0</td>
<td>0</td>
<td>0</td>
<td>NA</td>
</tr>
<tr class="odd">
<td>M5GNA2100</td>
<td>gpt-4o-mini-2024-07-18</td>
<td>0</td>
<td>1</td>
<td>0</td>
<td>0</td>
<td>0</td>
<td>0</td>
<td>0</td>
<td>0</td>
<td>NA</td>
</tr>
<tr class="even">
<td>M5GNA2100</td>
<td>gpt-4o-2024-08-06</td>
<td>0</td>
<td>1</td>
<td>0</td>
<td>0</td>
<td>0</td>
<td>0</td>
<td>0</td>
<td>0</td>
<td>NA</td>
</tr>
<tr class="odd">
<td>M5GNA2100</td>
<td>human2</td>
<td>0</td>
<td>1</td>
<td>0</td>
<td>0</td>
<td>0</td>
<td>0</td>
<td>0</td>
<td>0</td>
<td>NA</td>
</tr>
<tr class="even">
<td>M5GNA2100</td>
<td>human1</td>
<td>0</td>
<td>1</td>
<td>0</td>
<td>0</td>
<td>0</td>
<td>0</td>
<td>0</td>
<td>0</td>
<td>NA</td>
</tr>
<tr class="odd">
<td>M5GNA2200</td>
<td>gpt-4o-mini-2024-07-18</td>
<td>0</td>
<td>0</td>
<td>1</td>
<td>0</td>
<td>1</td>
<td>0</td>
<td>0</td>
<td>0</td>
<td>NA</td>
</tr>
<tr class="even">
<td>M5GNA2200</td>
<td>gpt-4o-2024-08-06</td>
<td>0</td>
<td>0</td>
<td>1</td>
<td>0</td>
<td>0</td>
<td>0</td>
<td>0</td>
<td>0</td>
<td>NA</td>
</tr>
<tr class="odd">
<td>M5GNA2200</td>
<td>human2</td>
<td>0</td>
<td>0</td>
<td>1</td>
<td>0</td>
<td>0</td>
<td>0</td>
<td>0</td>
<td>0</td>
<td>NA</td>
</tr>
<tr class="even">
<td>M5GNA2200</td>
<td>human1</td>
<td>0</td>
<td>0</td>
<td>1</td>
<td>0</td>
<td>0</td>
<td>0</td>
<td>0</td>
<td>0</td>
<td>NA</td>
</tr>
<tr class="odd">
<td>M5GNA3100</td>
<td>gpt-4o-mini-2024-07-18</td>
<td>0</td>
<td>1</td>
<td>0</td>
<td>1</td>
<td>1</td>
<td>0</td>
<td>0</td>
<td>0</td>
<td>NA</td>
</tr>
<tr class="even">
<td>M5GNA3100</td>
<td>gpt-4o-2024-08-06</td>
<td>0</td>
<td>1</td>
<td>0</td>
<td>1</td>
<td>0</td>
<td>0</td>
<td>0</td>
<td>0</td>
<td>NA</td>
</tr>
<tr class="odd">
<td>M5GNA3100</td>
<td>human2</td>
<td>0</td>
<td>1</td>
<td>0</td>
<td>1</td>
<td>0</td>
<td>0</td>
<td>0</td>
<td>0</td>
<td>NA</td>
</tr>
<tr class="even">
<td>M5GNA3100</td>
<td>human1</td>
<td>0</td>
<td>1</td>
<td>0</td>
<td>1</td>
<td>0</td>
<td>0</td>
<td>0</td>
<td>0</td>
<td>NA</td>
</tr>
<tr class="odd">
<td>M5GP1000</td>
<td>gpt-4o-mini-2024-07-18</td>
<td>0</td>
<td>0</td>
<td>0</td>
<td>0</td>
<td>0</td>
<td>0</td>
<td>1</td>
<td>0</td>
<td>NA</td>
</tr>
<tr class="even">
<td>M5GP1000</td>
<td>gpt-4o-2024-08-06</td>
<td>0</td>
<td>0</td>
<td>0</td>
<td>0</td>
<td>0</td>
<td>0</td>
<td>1</td>
<td>0</td>
<td>NA</td>
</tr>
<tr class="odd">
<td>M5GP1000</td>
<td>human2</td>
<td>0</td>
<td>0</td>
<td>0</td>
<td>0</td>
<td>0</td>
<td>0</td>
<td>1</td>
<td>0</td>
<td>NA</td>
</tr>
<tr class="even">
<td>M5GP1000</td>
<td>human1</td>
<td>0</td>
<td>0</td>
<td>0</td>
<td>0</td>
<td>0</td>
<td>0</td>
<td>1</td>
<td>0</td>
<td>NA</td>
</tr>
<tr class="odd">
<td>M5GPE1100</td>
<td>gpt-4o-mini-2024-07-18</td>
<td>0</td>
<td>0</td>
<td>1</td>
<td>1</td>
<td>0</td>
<td>0</td>
<td>0</td>
<td>0</td>
<td>NA</td>
</tr>
<tr class="even">
<td>M5GPE1100</td>
<td>gpt-4o-2024-08-06</td>
<td>0</td>
<td>0</td>
<td>1</td>
<td>0</td>
<td>0</td>
<td>0</td>
<td>0</td>
<td>0</td>
<td>NA</td>
</tr>
<tr class="odd">
<td>M5GPE1100</td>
<td>human1</td>
<td>0</td>
<td>0</td>
<td>1</td>
<td>0</td>
<td>0</td>
<td>0</td>
<td>0</td>
<td>0</td>
<td>NA</td>
</tr>
<tr class="even">
<td>M5GPE1100</td>
<td>human2</td>
<td>0</td>
<td>0</td>
<td>1</td>
<td>0</td>
<td>0</td>
<td>0</td>
<td>0</td>
<td>0</td>
<td>NA</td>
</tr>
<tr class="odd">
<td>M5GPE2100</td>
<td>gpt-4o-mini-2024-07-18</td>
<td>0</td>
<td>0</td>
<td>0</td>
<td>1</td>
<td>0</td>
<td>0</td>
<td>0</td>
<td>0</td>
<td>NA</td>
</tr>
<tr class="even">
<td>M5GPE2100</td>
<td>gpt-4o-2024-08-06</td>
<td>0</td>
<td>0</td>
<td>0</td>
<td>1</td>
<td>0</td>
<td>0</td>
<td>0</td>
<td>0</td>
<td>NA</td>
</tr>
<tr class="odd">
<td>M5GPE2100</td>
<td>human2</td>
<td>0</td>
<td>0</td>
<td>0</td>
<td>1</td>
<td>0</td>
<td>0</td>
<td>0</td>
<td>0</td>
<td>NA</td>
</tr>
<tr class="even">
<td>M5GPE2100</td>
<td>human1</td>
<td>0</td>
<td>0</td>
<td>0</td>
<td>1</td>
<td>0</td>
<td>0</td>
<td>0</td>
<td>0</td>
<td>NA</td>
</tr>
<tr class="odd">
<td>M5GRL2100</td>
<td>gpt-4o-mini-2024-07-18</td>
<td>0</td>
<td>1</td>
<td>0</td>
<td>0</td>
<td>0</td>
<td>0</td>
<td>1</td>
<td>0</td>
<td>NA</td>
</tr>
<tr class="even">
<td>M5GRL2100</td>
<td>gpt-4o-2024-08-06</td>
<td>0</td>
<td>1</td>
<td>0</td>
<td>0</td>
<td>0</td>
<td>0</td>
<td>0</td>
<td>0</td>
<td>NA</td>
</tr>
<tr class="odd">
<td>M5GRL2100</td>
<td>human1</td>
<td>0</td>
<td>1</td>
<td>0</td>
<td>0</td>
<td>0</td>
<td>0</td>
<td>0</td>
<td>0</td>
<td>NA</td>
</tr>
<tr class="even">
<td>M5GRL2100</td>
<td>human2</td>
<td>0</td>
<td>1</td>
<td>0</td>
<td>0</td>
<td>0</td>
<td>0</td>
<td>0</td>
<td>0</td>
<td>NA</td>
</tr>
<tr class="odd">
<td>M5GRL2200</td>
<td>gpt-4o-mini-2024-07-18</td>
<td>0</td>
<td>0</td>
<td>0</td>
<td>0</td>
<td>0</td>
<td>0</td>
<td>0</td>
<td>0</td>
<td>NA</td>
</tr>
<tr class="even">
<td>M5GRL2200</td>
<td>gpt-4o-2024-08-06</td>
<td>0</td>
<td>0</td>
<td>0</td>
<td>1</td>
<td>0</td>
<td>0</td>
<td>0</td>
<td>0</td>
<td>NA</td>
</tr>
<tr class="odd">
<td>M5GRL2200</td>
<td>human1</td>
<td>0</td>
<td>0</td>
<td>0</td>
<td>1</td>
<td>0</td>
<td>0</td>
<td>0</td>
<td>0</td>
<td>NA</td>
</tr>
<tr class="even">
<td>M5GRL2200</td>
<td>human2</td>
<td>0</td>
<td>0</td>
<td>0</td>
<td>1</td>
<td>0</td>
<td>0</td>
<td>0</td>
<td>0</td>
<td>NA</td>
</tr>
<tr class="odd">
<td>MGKH2100</td>
<td>gpt-4o-mini-2024-07-18</td>
<td>0</td>
<td>1</td>
<td>0</td>
<td>1</td>
<td>0</td>
<td>1</td>
<td>0</td>
<td>0</td>
<td>NA</td>
</tr>
<tr class="even">
<td>MGKH2100</td>
<td>gpt-4o-2024-08-06</td>
<td>0</td>
<td>0</td>
<td>0</td>
<td>1</td>
<td>0</td>
<td>1</td>
<td>0</td>
<td>0</td>
<td>NA</td>
</tr>
<tr class="odd">
<td>MGKH2100</td>
<td>human1</td>
<td>0</td>
<td>0</td>
<td>0</td>
<td>1</td>
<td>0</td>
<td>0</td>
<td>0</td>
<td>1</td>
<td>Refleksjonsnotat tilknyttet trukket tema leveres før eksamen. Så
muntlig og digital presentasjon.</td>
</tr>
<tr class="even">
<td>MGKH2100</td>
<td>human2</td>
<td>0</td>
<td>1</td>
<td>0</td>
<td>1</td>
<td>0</td>
<td>0</td>
<td>0</td>
<td>0</td>
<td>NA</td>
</tr>
<tr class="odd">
<td>MGKH3100</td>
<td>gpt-4o-mini-2024-07-18</td>
<td>0</td>
<td>1</td>
<td>0</td>
<td>0</td>
<td>1</td>
<td>0</td>
<td>0</td>
<td>0</td>
<td>NA</td>
</tr>
<tr class="even">
<td>MGKH3100</td>
<td>gpt-4o-2024-08-06</td>
<td>0</td>
<td>1</td>
<td>0</td>
<td>0</td>
<td>1</td>
<td>0</td>
<td>0</td>
<td>0</td>
<td>NA</td>
</tr>
<tr class="odd">
<td>MGKH3100</td>
<td>human1</td>
<td>0</td>
<td>1</td>
<td>0</td>
<td>0</td>
<td>1</td>
<td>0</td>
<td>0</td>
<td>0</td>
<td>NA</td>
</tr>
<tr class="even">
<td>MGKH3100</td>
<td>human2</td>
<td>0</td>
<td>1</td>
<td>0</td>
<td>0</td>
<td>1</td>
<td>0</td>
<td>0</td>
<td>0</td>
<td>NA</td>
</tr>
<tr class="odd">
<td>MGKP4101</td>
<td>gpt-4o-mini-2024-07-18</td>
<td>0</td>
<td>1</td>
<td>0</td>
<td>0</td>
<td>0</td>
<td>0</td>
<td>0</td>
<td>0</td>
<td>NA</td>
</tr>
<tr class="even">
<td>MGKP4101</td>
<td>gpt-4o-2024-08-06</td>
<td>0</td>
<td>1</td>
<td>0</td>
<td>0</td>
<td>0</td>
<td>0</td>
<td>0</td>
<td>0</td>
<td>NA</td>
</tr>
<tr class="odd">
<td>MGKP4101</td>
<td>human2</td>
<td>0</td>
<td>1</td>
<td>0</td>
<td>0</td>
<td>0</td>
<td>0</td>
<td>0</td>
<td>0</td>
<td>NA</td>
</tr>
<tr class="even">
<td>MGLU1501</td>
<td>human3</td>
<td>0</td>
<td>0</td>
<td>1</td>
<td>0</td>
<td>0</td>
<td>0</td>
<td>0</td>
<td>0</td>
<td>NA</td>
</tr>
<tr class="odd">
<td>MGLU3513</td>
<td>human3</td>
<td>0</td>
<td>0</td>
<td>1</td>
<td>0</td>
<td>0</td>
<td>0</td>
<td>0</td>
<td>1</td>
<td>Gruppeoppgave</td>
</tr>
<tr class="even">
<td>MGLU3522</td>
<td>human3</td>
<td>0</td>
<td>1</td>
<td>1</td>
<td>1</td>
<td>0</td>
<td>0</td>
<td>0</td>
<td>0</td>
<td>NA</td>
</tr>
<tr class="odd">
<td>MGLU4213</td>
<td>human3</td>
<td>0</td>
<td>0</td>
<td>0</td>
<td>0</td>
<td>0</td>
<td>0</td>
<td>0</td>
<td>1</td>
<td>Oppgave</td>
</tr>
<tr class="even">
<td>MGLU5203</td>
<td>human3</td>
<td>0</td>
<td>0</td>
<td>1</td>
<td>0</td>
<td>0</td>
<td>0</td>
<td>0</td>
<td>0</td>
<td>NA</td>
</tr>
<tr class="odd">
<td>MGMO5900</td>
<td>gpt-4o-mini-2024-07-18</td>
<td>0</td>
<td>1</td>
<td>0</td>
<td>1</td>
<td>0</td>
<td>0</td>
<td>0</td>
<td>0</td>
<td>NA</td>
</tr>
<tr class="even">
<td>MGMO5900</td>
<td>gpt-4o-2024-08-06</td>
<td>0</td>
<td>1</td>
<td>0</td>
<td>1</td>
<td>0</td>
<td>0</td>
<td>0</td>
<td>0</td>
<td>NA</td>
</tr>
<tr class="odd">
<td>MGMO5900</td>
<td>human2</td>
<td>0</td>
<td>1</td>
<td>0</td>
<td>0</td>
<td>0</td>
<td>0</td>
<td>0</td>
<td>0</td>
<td>NA</td>
</tr>
<tr class="even">
<td>MGMU4200</td>
<td>gpt-4o-mini-2024-07-18</td>
<td>0</td>
<td>1</td>
<td>0</td>
<td>0</td>
<td>0</td>
<td>0</td>
<td>0</td>
<td>0</td>
<td>NA</td>
</tr>
<tr class="odd">
<td>MGMU4200</td>
<td>gpt-4o-2024-08-06</td>
<td>0</td>
<td>1</td>
<td>0</td>
<td>0</td>
<td>0</td>
<td>0</td>
<td>0</td>
<td>0</td>
<td>NA</td>
</tr>
<tr class="even">
<td>MGMU4200</td>
<td>human2</td>
<td>0</td>
<td>1</td>
<td>0</td>
<td>0</td>
<td>0</td>
<td>0</td>
<td>0</td>
<td>0</td>
<td>NA</td>
</tr>
<tr class="odd">
<td>MGNO4200</td>
<td>gpt-4o-mini-2024-07-18</td>
<td>0</td>
<td>1</td>
<td>0</td>
<td>1</td>
<td>0</td>
<td>0</td>
<td>0</td>
<td>0</td>
<td>NA</td>
</tr>
<tr class="even">
<td>MGNO4200</td>
<td>gpt-4o-2024-08-06</td>
<td>0</td>
<td>0</td>
<td>0</td>
<td>1</td>
<td>0</td>
<td>0</td>
<td>0</td>
<td>0</td>
<td>NA</td>
</tr>
<tr class="odd">
<td>MGNO4200</td>
<td>human2</td>
<td>1</td>
<td>0</td>
<td>0</td>
<td>0</td>
<td>0</td>
<td>0</td>
<td>0</td>
<td>0</td>
<td>NA</td>
</tr>
<tr class="even">
<td>MGPE3300</td>
<td>gpt-4o-mini-2024-07-18</td>
<td>0</td>
<td>1</td>
<td>0</td>
<td>0</td>
<td>0</td>
<td>0</td>
<td>0</td>
<td>0</td>
<td>NA</td>
</tr>
<tr class="odd">
<td>MGPE3300</td>
<td>gpt-4o-2024-08-06</td>
<td>0</td>
<td>1</td>
<td>0</td>
<td>0</td>
<td>0</td>
<td>0</td>
<td>0</td>
<td>0</td>
<td>NA</td>
</tr>
<tr class="even">
<td>MGPE3300</td>
<td>human2</td>
<td>0</td>
<td>1</td>
<td>0</td>
<td>0</td>
<td>0</td>
<td>0</td>
<td>0</td>
<td>0</td>
<td>NA</td>
</tr>
<tr class="odd">
<td>MGPE3300</td>
<td>human1</td>
<td>0</td>
<td>1</td>
<td>0</td>
<td>0</td>
<td>0</td>
<td>0</td>
<td>0</td>
<td>0</td>
<td>NA</td>
</tr>
<tr class="even">
<td>MGSF5100</td>
<td>gpt-4o-mini-2024-07-18</td>
<td>0</td>
<td>0</td>
<td>0</td>
<td>0</td>
<td>0</td>
<td>0</td>
<td>0</td>
<td>0</td>
<td>NA</td>
</tr>
<tr class="odd">
<td>MGSF5100</td>
<td>gpt-4o-2024-08-06</td>
<td>0</td>
<td>0</td>
<td>0</td>
<td>1</td>
<td>0</td>
<td>0</td>
<td>0</td>
<td>0</td>
<td>NA</td>
</tr>
<tr class="even">
<td>MGSF5100</td>
<td>human2</td>
<td>0</td>
<td>0</td>
<td>0</td>
<td>1</td>
<td>0</td>
<td>0</td>
<td>0</td>
<td>0</td>
<td>NA</td>
</tr>
<tr class="odd">
<td>MGVM4100</td>
<td>gpt-4o-mini-2024-07-18</td>
<td>1</td>
<td>0</td>
<td>1</td>
<td>0</td>
<td>0</td>
<td>0</td>
<td>0</td>
<td>0</td>
<td>NA</td>
</tr>
<tr class="even">
<td>MGVM4100</td>
<td>gpt-4o-2024-08-06</td>
<td>0</td>
<td>0</td>
<td>1</td>
<td>0</td>
<td>0</td>
<td>0</td>
<td>0</td>
<td>0</td>
<td>NA</td>
</tr>
<tr class="odd">
<td>MGVM4100</td>
<td>human2</td>
<td>0</td>
<td>0</td>
<td>1</td>
<td>0</td>
<td>0</td>
<td>0</td>
<td>0</td>
<td>0</td>
<td>NA</td>
</tr>
<tr class="even">
<td>PPU4602</td>
<td>human3</td>
<td>0</td>
<td>0</td>
<td>0</td>
<td>1</td>
<td>0</td>
<td>0</td>
<td>0</td>
<td>0</td>
<td>NA</td>
</tr>
</tbody>
</table>

Hvis man ser på den dyre modellen, “gpt-4o”, er det knapt mulig å spore
uenighet med menneskene, men noen er det:

-   MGKH2100 (kunst og håndverk), språkmodellen finner en mappeeksamen
    som menneskene ikke finner. Ett menneske ser et refleksjonsnotat som
    ingen andre finner. MGKH2100 har muntlig eksamen der studentene skal
    levere et refleksjonsnotat på forhånd. Det er også en
    mappeinnlevering som en obligatorisk del av kurset. Kun det ene
    mennesket kodet riktig.  
-   MGMO5900 (masteremnet), språkmodellen koder at de entreprenøriellene
    masterne har muntlig forsvar av graden, men menneskene sier kun
    skriftlig eksamen. Språkmodellen har rett, men dette kan diskuteres.
-   MGNO4200 (norsk), språkmodellen finner en muntlig eksamen, mens
    mennesket finner ingen. Språkmodellen har rett.

Språkmodellen kodet altså jevngodt eller såvidt bedre enn menneskene.

## Arbeidskrav

Nå har jeg funnet ut at “gpt-4o-mini” bare er for dårlig, så jeg viser
ikke den i disse dataene.

Jeg fant ut at den beste måten å kode dette på var å ikke ha “ja/nei” på
hver enkelt arbeidskravstype, men kode antallet av hver type
arbeidskrav. Da kunne man summere opp totalt antall arbeidskrav på
slutten, og man trenger ikke å basere seg på at språkmodellen kan telle,
noe de er dårlige til.

``` r
arbeidskrav <- read_rds("data/arbeidskrav.Rds")

arbeidskrav |> filter(koder != "gpt-4o-mini-2024-07-18") |> select(-gpt_response) |> tinytable::tt()
```

<table style="width:98%;">
<colgroup>
<col style="width: 2%" />
<col style="width: 3%" />
<col style="width: 3%" />
<col style="width: 4%" />
<col style="width: 4%" />
<col style="width: 4%" />
<col style="width: 4%" />
<col style="width: 4%" />
<col style="width: 4%" />
<col style="width: 4%" />
<col style="width: 58%" />
</colgroup>
<thead>
<tr class="header">
<th>emnekode</th>
<th>koder</th>
<th>Arbeidskravantall</th>
<th>Arbeidskravformat.1</th>
<th>Arbeidskravformat.2</th>
<th>Arbeidskravformat.3</th>
<th>Arbeidskravformat.4</th>
<th>Arbeidskravformat.5</th>
<th>Arbeidskravformat.6</th>
<th>Arbeidskravformat.7</th>
<th>Arbeidskravformat_annet</th>
</tr>
</thead>
<tbody>
<tr class="odd">
<td>M5GEN1100</td>
<td>gpt-4o-2024-08-06</td>
<td>2</td>
<td>NA</td>
<td>1</td>
<td>1</td>
<td>0</td>
<td>0</td>
<td>0</td>
<td>0</td>
<td>NA</td>
</tr>
<tr class="even">
<td>M5GEN1100</td>
<td>human1</td>
<td>2</td>
<td>0</td>
<td>1</td>
<td>1</td>
<td>0</td>
<td>0</td>
<td>0</td>
<td>1</td>
<td>Krav om deltakelse i undervisningen (som beskrevet under
«Arbeidskrav» i den innledende delen av fagplanen).</td>
</tr>
<tr class="odd">
<td>M5GEN1100</td>
<td>human2</td>
<td>3</td>
<td>0</td>
<td>1</td>
<td>1</td>
<td>0</td>
<td>0</td>
<td>0</td>
<td>1</td>
<td>Deltagelse i obligatorisk undervisning på campus</td>
</tr>
<tr class="even">
<td>M5GEN2100</td>
<td>gpt-4o-2024-08-06</td>
<td>8</td>
<td>NA</td>
<td>3</td>
<td>1</td>
<td>0</td>
<td>0</td>
<td>0</td>
<td>4</td>
<td>NA</td>
</tr>
<tr class="odd">
<td>M5GEN2100</td>
<td>human1</td>
<td>5</td>
<td>0</td>
<td>1</td>
<td>1</td>
<td>0</td>
<td>0</td>
<td>0</td>
<td>1</td>
<td>5 arb krav i 1-2 år, 7 arb krav i 3 år. Deltagelse i undervisningen,
kurs, flerfaglig undervisning, veiledning og konferanse.</td>
</tr>
<tr class="even">
<td>M5GEN2100</td>
<td>human2</td>
<td>5</td>
<td>0</td>
<td>1</td>
<td>1</td>
<td>0</td>
<td>0</td>
<td>0</td>
<td>1</td>
<td>Deltagelse i obligatorisk undervisning på campus</td>
</tr>
<tr class="odd">
<td>M5GMT2100</td>
<td>gpt-4o-2024-08-06</td>
<td>1</td>
<td>NA</td>
<td>0</td>
<td>0</td>
<td>0</td>
<td>1</td>
<td>0</td>
<td>0</td>
<td>NA</td>
</tr>
<tr class="even">
<td>M5GMT2100</td>
<td>human2</td>
<td>2</td>
<td>0</td>
<td>0</td>
<td>0</td>
<td>0</td>
<td>1</td>
<td>0</td>
<td>1</td>
<td>Deltagelse i obligatorisk undervisning på campus</td>
</tr>
<tr class="odd">
<td>M5GMT2100</td>
<td>human1</td>
<td>2</td>
<td>0</td>
<td>0</td>
<td>0</td>
<td>0</td>
<td>1</td>
<td>0</td>
<td>1</td>
<td>Krav om deltakelse i undervisningen</td>
</tr>
<tr class="even">
<td>M5GNA2100</td>
<td>gpt-4o-2024-08-06</td>
<td>5</td>
<td>NA</td>
<td>2</td>
<td>1</td>
<td>0</td>
<td>2</td>
<td>0</td>
<td>0</td>
<td>NA</td>
</tr>
<tr class="odd">
<td>M5GNA2100</td>
<td>human2</td>
<td>7</td>
<td>0</td>
<td>1</td>
<td>1</td>
<td>0</td>
<td>1</td>
<td>0</td>
<td>1</td>
<td>Deltagelse i obligatorisk undervisning på campus</td>
</tr>
<tr class="even">
<td>M5GNA2100</td>
<td>human1</td>
<td>3</td>
<td>0</td>
<td>1</td>
<td>1</td>
<td>0</td>
<td>0</td>
<td>0</td>
<td>1</td>
<td>Gjennomføre et undervisningsopplegg i naturfag, designe og lage to
modeller knyttet til ulike deler i naturfag og hverandrevurdering. I
tillegg 100 prosent obligatorisk oppmøte på presentasjonsdag,
sikkerhetskurs og undervisning i teknologi og design. Det er også krav
om flere flerfaglige arbeidskrav.</td>
</tr>
<tr class="odd">
<td>M5GNA2200</td>
<td>gpt-4o-2024-08-06</td>
<td>3</td>
<td>NA</td>
<td>1</td>
<td>0</td>
<td>0</td>
<td>1</td>
<td>1</td>
<td>0</td>
<td>NA</td>
</tr>
<tr class="even">
<td>M5GNA2200</td>
<td>human2</td>
<td>4</td>
<td>0</td>
<td>1</td>
<td>1</td>
<td>0</td>
<td>0</td>
<td>1</td>
<td>1</td>
<td>Deltagelse i obligatorisk undervisning på campus</td>
</tr>
<tr class="odd">
<td>M5GNA2200</td>
<td>human1</td>
<td>3</td>
<td>0</td>
<td>1</td>
<td>0</td>
<td>0</td>
<td>1</td>
<td>1</td>
<td>0</td>
<td>NA</td>
</tr>
<tr class="even">
<td>M5GNA3100</td>
<td>gpt-4o-2024-08-06</td>
<td>6</td>
<td>NA</td>
<td>3</td>
<td>1</td>
<td>1</td>
<td>0</td>
<td>1</td>
<td>0</td>
<td>NA</td>
</tr>
<tr class="odd">
<td>M5GNA3100</td>
<td>human2</td>
<td>12</td>
<td>0</td>
<td>1</td>
<td>1</td>
<td>0</td>
<td>0</td>
<td>1</td>
<td>1</td>
<td>Deltagelse i obligatorisk undervisning på campus</td>
</tr>
<tr class="even">
<td>M5GNA3100</td>
<td>human1</td>
<td>9</td>
<td>0</td>
<td>1</td>
<td>1</td>
<td>1</td>
<td>1</td>
<td>1</td>
<td>1</td>
<td>Utvikle et undervisningsopplegg, digital rapport med 20 objekter,
deltagelse på kurs, seminarer og konferanser.</td>
</tr>
<tr class="odd">
<td>M5GP1000</td>
<td>gpt-4o-2024-08-06</td>
<td>0</td>
<td>NA</td>
<td>0</td>
<td>0</td>
<td>0</td>
<td>0</td>
<td>0</td>
<td>0</td>
<td>NA</td>
</tr>
<tr class="even">
<td>M5GP1000</td>
<td>human2</td>
<td>1</td>
<td>0</td>
<td>0</td>
<td>0</td>
<td>0</td>
<td>0</td>
<td>0</td>
<td>1</td>
<td>Obligatorisk praksisdeltagelse</td>
</tr>
<tr class="odd">
<td>M5GP1000</td>
<td>human1</td>
<td>0</td>
<td>1</td>
<td>0</td>
<td>0</td>
<td>0</td>
<td>0</td>
<td>0</td>
<td>0</td>
<td>NA</td>
</tr>
<tr class="even">
<td>M5GPE1100</td>
<td>gpt-4o-2024-08-06</td>
<td>5</td>
<td>NA</td>
<td>3</td>
<td>0</td>
<td>0</td>
<td>1</td>
<td>0</td>
<td>1</td>
<td>NA</td>
</tr>
<tr class="odd">
<td>M5GPE1100</td>
<td>human1</td>
<td>4</td>
<td>0</td>
<td>1</td>
<td>1</td>
<td>0</td>
<td>0</td>
<td>0</td>
<td>1</td>
<td>Deltagelse i lesegruppe 3 ganger. Deltagelse i undervisning og fire
spesifikke kurs.</td>
</tr>
<tr class="even">
<td>M5GPE1100</td>
<td>human2</td>
<td>9</td>
<td>0</td>
<td>1</td>
<td>1</td>
<td>0</td>
<td>1</td>
<td>0</td>
<td>1</td>
<td>Deltagelse i obligatorisk undervisning på campus</td>
</tr>
<tr class="odd">
<td>M5GPE2100</td>
<td>gpt-4o-2024-08-06</td>
<td>3</td>
<td>NA</td>
<td>2</td>
<td>1</td>
<td>0</td>
<td>0</td>
<td>0</td>
<td>0</td>
<td>NA</td>
</tr>
<tr class="even">
<td>M5GPE2100</td>
<td>human2</td>
<td>8</td>
<td>0</td>
<td>1</td>
<td>1</td>
<td>0</td>
<td>0</td>
<td>0</td>
<td>1</td>
<td>Deltagelse i obligatorisk undervisning på campus</td>
</tr>
<tr class="odd">
<td>M5GPE2100</td>
<td>human1</td>
<td>3</td>
<td>0</td>
<td>1</td>
<td>1</td>
<td>0</td>
<td>0</td>
<td>0</td>
<td>1</td>
<td>Deltagelse i kurs: i forskningsmetode, i akademisk skriving og
førstehjelpskurs. I tillegg nevnes deltagelse i flerfaglig tema om barn,
ungdom og helse.</td>
</tr>
<tr class="even">
<td>M5GRL2100</td>
<td>gpt-4o-2024-08-06</td>
<td>3</td>
<td>NA</td>
<td>1</td>
<td>0</td>
<td>0</td>
<td>0</td>
<td>1</td>
<td>1</td>
<td>NA</td>
</tr>
<tr class="odd">
<td>M5GRL2100</td>
<td>human1</td>
<td>4</td>
<td>0</td>
<td>1</td>
<td>0</td>
<td>0</td>
<td>0</td>
<td>1</td>
<td>1</td>
<td>Arbeidskrav er oppmøte i undervisning, deltagelse i verksted,
deltagelse på ekskursjoner, og individuell veiledning i forbindelse med
fordypningsoppgaven.</td>
</tr>
<tr class="even">
<td>M5GRL2100</td>
<td>human2</td>
<td>4</td>
<td>0</td>
<td>0</td>
<td>1</td>
<td>0</td>
<td>0</td>
<td>1</td>
<td>1</td>
<td>Deltagelse i obligatorisk undervisning på campus</td>
</tr>
<tr class="odd">
<td>M5GRL2200</td>
<td>gpt-4o-2024-08-06</td>
<td>4</td>
<td>NA</td>
<td>1</td>
<td>0</td>
<td>0</td>
<td>0</td>
<td>1</td>
<td>2</td>
<td>NA</td>
</tr>
<tr class="even">
<td>M5GRL2200</td>
<td>human1</td>
<td>4</td>
<td>0</td>
<td>0</td>
<td>0</td>
<td>0</td>
<td>0</td>
<td>0</td>
<td>1</td>
<td>Arbeidskrav er oppmøte i undervisning, deltagelse i verksted og
deltagelse på ekskursjoner. Emneplanen henviser til programplanen for
mer informasjon, og fagplanen henviser til emneplanen.</td>
</tr>
<tr class="odd">
<td>M5GRL2200</td>
<td>human2</td>
<td>3</td>
<td>0</td>
<td>0</td>
<td>1</td>
<td>0</td>
<td>0</td>
<td>1</td>
<td>1</td>
<td>Deltagelse i obligatorisk undervisning på campus</td>
</tr>
<tr class="even">
<td>MGKH2100</td>
<td>gpt-4o-2024-08-06</td>
<td>7</td>
<td>NA</td>
<td>1</td>
<td>1</td>
<td>1</td>
<td>4</td>
<td>0</td>
<td>0</td>
<td>NA</td>
</tr>
<tr class="odd">
<td>MGKH2100</td>
<td>human1</td>
<td>4</td>
<td>0</td>
<td>1</td>
<td>0</td>
<td>0</td>
<td>1</td>
<td>0</td>
<td>1</td>
<td>Flerfaglig arbeidskrav</td>
</tr>
<tr class="even">
<td>MGKH2100</td>
<td>human2</td>
<td>4</td>
<td>0</td>
<td>1</td>
<td>0</td>
<td>0</td>
<td>1</td>
<td>0</td>
<td>0</td>
<td>NA</td>
</tr>
<tr class="odd">
<td>MGKH3100</td>
<td>gpt-4o-2024-08-06</td>
<td>6</td>
<td>NA</td>
<td>2</td>
<td>2</td>
<td>0</td>
<td>1</td>
<td>1</td>
<td>0</td>
<td>NA</td>
</tr>
<tr class="even">
<td>MGKH3100</td>
<td>human1</td>
<td>3</td>
<td>0</td>
<td>1</td>
<td>1</td>
<td>0</td>
<td>0</td>
<td>0</td>
<td>1</td>
<td>Deltagelse på workshops, fagseminarer, veiledning og presentasjon på
seminar. I tillegg deltagelse på undervisning i vitenskap og metode,
akademisk skriving og delingskonferanse.</td>
</tr>
<tr class="odd">
<td>MGKH3100</td>
<td>human2</td>
<td>11</td>
<td>0</td>
<td>1</td>
<td>1</td>
<td>0</td>
<td>0</td>
<td>0</td>
<td>1</td>
<td>Deltagelse i obligatorisk undervisning på campus</td>
</tr>
<tr class="even">
<td>MGKP4101</td>
<td>gpt-4o-2024-08-06</td>
<td>2</td>
<td>NA</td>
<td>1</td>
<td>1</td>
<td>0</td>
<td>0</td>
<td>0</td>
<td>0</td>
<td>NA</td>
</tr>
<tr class="odd">
<td>MGKP4101</td>
<td>human2</td>
<td>2</td>
<td>0</td>
<td>1</td>
<td>1</td>
<td>0</td>
<td>0</td>
<td>0</td>
<td>1</td>
<td>Deltagelse i obligatorisk undervisning på campus</td>
</tr>
<tr class="even">
<td>MGLU1501</td>
<td>human3</td>
<td>0</td>
<td>0</td>
<td>1</td>
<td>1</td>
<td>0</td>
<td>0</td>
<td>0</td>
<td>0</td>
<td>NA</td>
</tr>
<tr class="odd">
<td>MGLU3513</td>
<td>human3</td>
<td>0</td>
<td>0</td>
<td>1</td>
<td>0</td>
<td>0</td>
<td>1</td>
<td>0</td>
<td>0</td>
<td>NA</td>
</tr>
<tr class="even">
<td>MGLU3522</td>
<td>human3</td>
<td>14</td>
<td>0</td>
<td>1</td>
<td>1</td>
<td>0</td>
<td>0</td>
<td>0</td>
<td>0</td>
<td>NA</td>
</tr>
<tr class="odd">
<td>MGLU4213</td>
<td>human3</td>
<td>2</td>
<td>0</td>
<td>1</td>
<td>1</td>
<td>0</td>
<td>1</td>
<td>0</td>
<td>0</td>
<td>NA</td>
</tr>
<tr class="even">
<td>MGLU5203</td>
<td>human3</td>
<td>5</td>
<td>1</td>
<td>0</td>
<td>0</td>
<td>0</td>
<td>0</td>
<td>0</td>
<td>0</td>
<td>NA</td>
</tr>
<tr class="odd">
<td>MGMO5900</td>
<td>gpt-4o-2024-08-06</td>
<td>2</td>
<td>NA</td>
<td>0</td>
<td>1</td>
<td>0</td>
<td>0</td>
<td>0</td>
<td>1</td>
<td>NA</td>
</tr>
<tr class="even">
<td>MGMO5900</td>
<td>human2</td>
<td>2</td>
<td>0</td>
<td>0</td>
<td>1</td>
<td>0</td>
<td>0</td>
<td>0</td>
<td>0</td>
<td>NA</td>
</tr>
<tr class="odd">
<td>MGMU4200</td>
<td>gpt-4o-2024-08-06</td>
<td>4</td>
<td>NA</td>
<td>2</td>
<td>0</td>
<td>0</td>
<td>1</td>
<td>0</td>
<td>1</td>
<td>NA</td>
</tr>
<tr class="even">
<td>MGMU4200</td>
<td>human2</td>
<td>3</td>
<td>0</td>
<td>1</td>
<td>0</td>
<td>0</td>
<td>1</td>
<td>0</td>
<td>0</td>
<td>NA</td>
</tr>
<tr class="odd">
<td>MGNO4200</td>
<td>gpt-4o-2024-08-06</td>
<td>3</td>
<td>NA</td>
<td>1</td>
<td>1</td>
<td>0</td>
<td>0</td>
<td>1</td>
<td>0</td>
<td>NA</td>
</tr>
<tr class="even">
<td>MGNO4200</td>
<td>human2</td>
<td>0</td>
<td>1</td>
<td>0</td>
<td>0</td>
<td>0</td>
<td>0</td>
<td>0</td>
<td>0</td>
<td>NA</td>
</tr>
<tr class="odd">
<td>MGPE3300</td>
<td>gpt-4o-2024-08-06</td>
<td>4</td>
<td>NA</td>
<td>4</td>
<td>0</td>
<td>0</td>
<td>0</td>
<td>0</td>
<td>0</td>
<td>NA</td>
</tr>
<tr class="even">
<td>MGPE3300</td>
<td>human2</td>
<td>9</td>
<td>0</td>
<td>1</td>
<td>1</td>
<td>0</td>
<td>0</td>
<td>1</td>
<td>1</td>
<td>Deltagelse i obligatorisk undervisning på campus</td>
</tr>
<tr class="odd">
<td>MGPE3300</td>
<td>human1</td>
<td>4</td>
<td>0</td>
<td>1</td>
<td>1</td>
<td>0</td>
<td>0</td>
<td>1</td>
<td>1</td>
<td>Deltagelse i paneldebatt</td>
</tr>
<tr class="even">
<td>MGSF5100</td>
<td>gpt-4o-2024-08-06</td>
<td>3</td>
<td>NA</td>
<td>3</td>
<td>0</td>
<td>0</td>
<td>0</td>
<td>0</td>
<td>0</td>
<td>NA</td>
</tr>
<tr class="odd">
<td>MGSF5100</td>
<td>human2</td>
<td>4</td>
<td>0</td>
<td>1</td>
<td>1</td>
<td>0</td>
<td>0</td>
<td>0</td>
<td>1</td>
<td>Deltagelse i obligatorisk undervisning på campus</td>
</tr>
<tr class="even">
<td>MGVM4100</td>
<td>gpt-4o-2024-08-06</td>
<td>0</td>
<td>NA</td>
<td>0</td>
<td>0</td>
<td>0</td>
<td>0</td>
<td>0</td>
<td>0</td>
<td>NA</td>
</tr>
<tr class="odd">
<td>MGVM4100</td>
<td>human2</td>
<td>0</td>
<td>1</td>
<td>0</td>
<td>0</td>
<td>0</td>
<td>0</td>
<td>0</td>
<td>0</td>
<td>NA</td>
</tr>
<tr class="even">
<td>PPU4602</td>
<td>human3</td>
<td>0</td>
<td>1</td>
<td>0</td>
<td>0</td>
<td>0</td>
<td>0</td>
<td>0</td>
<td>0</td>
<td>NA</td>
</tr>
</tbody>
</table>

Dette er det komplette kaos, men det er fordi det er vanskelig å bedømme
hva som er et arbeidskrav. Det er i hvert fall opplagt at menneskene
også er uenige seg imellom.

Jeg ba språkmodellen om å nevne hva den telte som arbeidskrav:

``` r
arbeidskrav |> filter(koder == "gpt-4o-2024-08-06") |> select(emnekode, gpt_response) |> print(n = 30)
```

    # A tibble: 20 × 2
    # Rowwise: 
       emnekode  gpt_response                                                       
       <chr>     <chr>                                                              
     1 M5GEN1100 "Skriftlig = 1 [Individuell skriftlig oppgave, tekst på 900 ord +/…
     2 M5GEN2100 "Skriftlig = 3 [Individuelt skriftlig notat, Notat på 400 ord om o…
     3 M5GMT2100 "Skriftlig = 0 []\n\nMuntlig = 0 []\n\nMultimodal = 0 []\n\nPrakti…
     4 M5GNA2100 "Skriftlig = 2 [Naturfagrapport fra naturfaglig forsøk, Fagdidakti…
     5 M5GNA2200 "Skriftlig = 1 [Individuell test i arter og objekter]\nMuntlig = 0…
     6 M5GNA3100 "Skriftlig = 3 [Individuell test i navnsetting og kjemiske beregni…
     7 M5GP1000  "Skriftlig = 0 []\n\nMuntlig = 0 []\n\nMultimodal = 0 []\n\nPrakti…
     8 M5GPE1100 "Skriftlig = 3 [Undervisningsplan med begrunnelse, fire fagnotater…
     9 M5GPE2100 "Skriftlig = 2 [Fagnotat basert på intervju, Fagnotat om oppvekst …
    10 M5GRL2100 "Skriftlig = 1 [Individuell skriftlig fordypningsoppgave basert på…
    11 M5GRL2200 "Skriftlig = 1 [Individuell rapport på 400 ord fra ekskursjonsbesø…
    12 MGKH2100  "Skriftlig = 1 [Refleksjonsnotat på 1500 ord knyttet til eksamenst…
    13 MGKH3100  "Skriftlig = 2 [Innlevering av notat om plan for praktisk utviklin…
    14 MGKP4101  "Skriftlig = 1 [Individuell, skriftlig semesteroppgave med omfang …
    15 MGMO5900  "Skriftlig = 0 []\nMuntlig = 1 [Presentasjon av utviklingsprosjekt…
    16 MGMU4200  "Skriftlig = 2 [Notat på 400-800 ord som begrunner skolekonsertens…
    17 MGNO4200  "Skriftlig = 1 [Masterskisse: Studenten skal levere en skisse på 1…
    18 MGPE3300  "Skriftlig = 4 [Tre fagtekster fra fellestemaets deltemaer, analys…
    19 MGSF5100  "Skriftlig = 3 [Notat med tema og problemstilling for masteroppgav…
    20 MGVM4100  "Skriftlig = 0 []\nMuntlig = 0 []\nMultimodal = 0 []\nPraktisk-est…

Jeg har ettergått noen av de arbeidskravene som språkmodellen nevner, og
alle jeg har sjekket står i emneplanen.

For meg virker det som om vi må definere arbeidskrav bedre. Av og til
teller de menneskelige koderne obligatorisk oppmøte som et arbeidskrav,
men av og til ikke. I prompten ba jeg språkmodellen om å ikke telle
eksamener og obligatorisk oppmøte som arbeidskrav, men det ser ut til at
den teller obligatorisk oppmøte av og til. Og det gjør jommen menneskene
også. 🙃

# Konklusjoner

Konklusjonene er vel som TEPS-prosjektet om mastergrader: menneskene og
språkmodellene koder ulikt, men det skyldes uklare koder. Jeg tror at
ved å klargjøre kodeskjemaet sammen med språkmodellene vil alle disse
variablene kunne kodes forholdsvis likt. Et lite spørsmålstegn bak
antall arbeidskrav, men dette skyldes ikke at språkmodellene er dårlige
til å gjøre opptellingen, snarere at det er vanskelig å definere hva som
er et arbeidskrav.
