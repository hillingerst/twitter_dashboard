# Twitter Dashboard

In R und Python geschriebenes [Dashboard](https://shiny.hillinger.me/twitter/) zur interaktiven Darstellung von Twitter Nachrichten.
Mit Barcharts, Line charts, Network Graphs und Slider zur Auswahl der Zeitintervalle.

## Welche Voraussetzungen braucht man

Ihr solltet folgendes betriebsbereit haben bevor ihr den Code für euer eigenes Projekt anpassen könnt.

- Shiny [Rstudio Server](https://shiny.rstudio.com/)
- [Mongodb](https://www.mongodb.com/)

> Kann man ohne Probleme lokal am Rechner laufen haben.

## Was macht welche File

- ```app.R``` Bestimmt die Darstellung eurer Applikation.
- ```global.R``` ist für die benötigten Libraries und die Locale verantwortlich.
- ```twitter.py``` Besorgt euch die Daten aus der Twitter API und schreibt sie in die Datenbank. 
- ```prep.R``` Holt die Daten aus der Datenbank und bereitet sie für das Dashboard auf.

## License

MIT