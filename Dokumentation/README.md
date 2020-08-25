# Latexklassen des Lehrstuhls für Datenverarbeitung
## Verwendung der Klassen
Informationen zur Installation dieser Klassen sind in den jeweiligen Textdateien
zu finden, in vielen Fällen ist es auch ausreichend die .cls und .bst-Dateien in
das jeweilige Quellverzeichnis des Dokuments zu kopieren, dann spart man sich
die globale Installation.

## Informationen für Entwickler und Fehlerkorrekturen
Änderungen sollten im [src/latex/ldv-Verzeichnis](src/latex/ldv) erfolgen,
typischerweise in [ldvcommon.dtx](src/latex/ldv/ldvcommon.dtx). Die eigentlichen
Klassendateien werden anschließend über den Aufruf ```latex ldvmain.ins```
erzeugt. Diese dann bitte unter [tex/latex/ldv](tex/latex/ldv) ablegen und ggf.
die Logdatei vor dem Commit löschen.

### Erstellen der Dokumentation (ldvguide.pdf)
Workflow:
```
lualatex ldvguide.tex
makeindex -s gind.ist ldvguide.idx
makeindex -s gglo.ist -o ldvguide.gls ldvguide.glo
lualatex ldvguide.tex
lualatex ldvguide.tex
```
