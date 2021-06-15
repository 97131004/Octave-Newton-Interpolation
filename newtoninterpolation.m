# newtoninterpolation.m (Newtoninterpolation)
#
clear all; #Setzen alle Variablen zurueck
#
# Eingabe (beim Ausfuehren):
# - Funktion f (Funktion mit der die interpolierte Funktion verglichen wird), vom Typ String, in Anfuehrungszeichen, z.B.: "sqrt(x-1)"
# - Matrix m von Punkten, vom Typ Matrix, mit x,y; pro Zeile, z.B.: [1,0;2,1;5,2;10,3]
# - Testwert zur Fehlerberechnung (x-Koordinate, um welche spaeter die Funktion geplottet wird), vom Typ Integer / Float, z.B.: 8
#
# Voraussetzungen zur korrekten Ausführung:
# - Inputfunktion ist eine 2D-Funktion
# - Inputfunktion benutzt die Laufvariable x
# - Inputmatrix hat nur Punkte, wo einem x-Wert nur ein y-Wert zugeordnet ist
# - Inputmatrix hat keine mehrere identische Punkte
#
# Optionale Einstellungen für das Plotten: (Aendern im Kopf der newtoninterpolation.m Datei)
#
twspace = 8; #Reservieren Platz (in LE) ausgehend vom Testwert in alle Richtungen zur Bestimmung der Raender der Plotanzeige
plotw = 900; #Breite des Plotfensters in px
ploth = 900; #Hoehe des Plotfenster in px
#
#
# Ausgabe:
# - Iterationsschritte mit allen in der Baumstruktur berechneten (delta^i y / delta^i x)
# - Alle Koeffizienten Ai
# - Interpolierte Funktion f2
# - Ergebnis der Testwerteinsetzung mit f(Testwert) und f2(Testwert)
# - Absoluter und relativer Fehler durch den Vergleich von f(Testwert) und f2(Testwert)
# - Plot der Funktionen f und f2, eingegebenen Punkte und berechneten Fehler
#
# Navigation innerhalb des Plotfensters (falls dieses via gnuplot angezeigt wird) mit:
# > Mausrad = Y-Achse
# > Shift + Mausrad = X-Achse
# > Control + Mausrad = ZOOM in/out
# > Rechte Maustaste = Vergroesserungsrechteck zeichnen
# > Mittlere Maustaste = Punkt setzen (zeigt seine Koordinaten an)

clc; #Loeschen Textausgabe
close all force; #Schliessen von allen Figurefenster (umgeht gnuplot Bug, loest Memoryleak)
set(0,'DefaultFigureVisible','off') #Machen Figurefenster unsichtbar (umgeht gnuplot Bug)
format long;
printf("### Newtoninterpolation ###\n\n")


########################################## INPUT

#{
# FAST-TEST (auskommentieren und den naechsten comment-block bis zum # MAIN einkommentieren)
f = @(x)sqrt(x-1); #f(x)
f_inl = "sqrt(x-1)";
#f = @(x)x^3+x^2+x-1; #f(x)
#f_inl = "x^3+x^2+x-1";
m = [1 0 ; 2 1 ; 5 2 ; 10 3]; ## "sqrt(x-1)" ## => 0,1,-0.16,0.016
#m = [0 -1 ; 1 2 ; 2 13 ; 3 38]; ## "x^3+x^2+x-1" ## => -1,3,4,1
tw = 8; #Testwert zum Berechnen der Fehler und Plotanzeige
twspace = 4; #Reservieren Platz (in LE) ausgehend vom Testwert in alle Richtungen zur Bestimmung der Raender der Plotanzeige
plotw = 900; #Breite des Plotfensters in px
ploth = 900; #Hoehe des Plotfenster in px
#}


##{

# Eingabe Funktion

dq_ = [' "']; #Zum Printen von Anfuehrungszeichen
dq = ['"'];
inputfstr = "";
#Ueblicherweise wird strcat Spaces beseitigen, benutzen deshalb Matrixkonkatenierung
inputfstr = ["Funktion f (als String, in Anfuehrungszeichen",dq_,dq, ') (z.B.',dq_,'sqrt(x-1)',dq,"): "];

f_inl = input(inputfstr); #Input der Funktion f
fprintf('\n')

if ischar(f_inl) == 0 #Brechen Programm ab, wenn kein String ist
  fprintf('Eingabe ist kein String.\n')
  return;
endif

f = f_inl;
f = strcat("@(x)", f); #Funktion f wird zur anonymen Funktion durch Anfuegen von @(x)
f = eval(f); #Evaluieren f

printf("Eingegebene Funktion f: \n\nf(x) = "),disp(f),disp("")

# Eingabe Matrix mit Punkten

m = input("Matrix m von Punkten (x,y; pro Zeile) (z.B. [1,0;2,1;5,2;10,3]): "); # Eingabe der Matrix m

if ismatrix(m) == 0 || isempty(m) #Brechen Programm ab, wenn keine oder leere Matrix ist
  fprintf('\nEingabe ist keine Matrix oder eine leere Matrix.\n')
  return;
endif

printf("\nEingegebene Matrix m: \n\n"),disp(m),disp("")

# Eingabe Testwert (x-Koordinate ; zum Berechnen der Fehler und Plotanzeige)

tw = input("Testwert (x-Koord ; zur Fehlerberechnung) (z.B. 8): "); # Eingabe des Testwertes tw 

if isnumeric(tw) == 0 #Brechen Programm ab, wenn keine Nummer ist
  fprintf('\nEingabe ist keine Nummer.\n')
  return;
endif

printf("\nEingegebener Testwert tw: \n\n"),disp(tw),disp("")

##}


########################################## MAIN


x = []; y = []; #Initialisieren Vektoren

for i = 1:rows(m)
  x = [x ; [m(i,1)]]; #Fuellen Vektor mit den x aus 1. Spalte der Inputmatrix
  y = [y ; [m(i,2)]]; #Fuellen Vektor mit den y aus 2. Spalte der Inputmatrix
endfor


# Hauptalgorithmus (rekursive Iteration durch Baumstruktur)

printf("Initialisierung: \n\n")
n = y #Matrix n wird alle naechstkleineren Iterationsvektore aus y_ enthalten
y_ = y; #Vektor y_ wird nach jeder Iteration geschrumpft

for k=1:rows(y)-1 #Iterieren durch alle Iterationslevel
  printf("Iteration: (Schritt %i) \n\n", k)
  t = []; #Temporaerer Vektor zum Fuellen der n Matrix wird zurueckgesetzt
  for i=1:rows(y_)-1 #Iterieren durch alle Elemente innerhalbs eines Iterationslevels
    dx = x(i+k) - x(i); #Delta x berechnen
    dy = (y_(i+1) - y_(i)); #Delta y berechnen
    printf("dy%i=%f, dx%i=%f; ",i,dy,i,dx)
    t = [t ; [dy / dx]]; #Fuegen dem t Vektor neuen Wert auf neuer Zeile hinzu
  endfor
  y_ = t; #Kopieren t in y_, welcher im naechsten Iterationslevel durch jeweils weniger Zeilen iterieren wird (rekursiver Prozess)
  for z=1:rows(n)-rows(t) #Fuellen t Vektor mit Nullen, um Dimensionsfehler beim Hinzufuegen zur n Matrix zu vermeiden
    t = [t ; [0]];
  endfor
  printf("\n\n")
  n = [n , [t]] #Fuegen n Matrix den t Vektor in korrekter Dimension hinzu
endfor

printf('Koeffizienten a0, a1, a2 , ... , ai:\n\n')

# Printen von a0, a1, a2, ...

for r=1:rows(y)
  printf('a%i = %.16f \n',r-1,n(1,r)) #Geben die erste Zeile der n Matrix aus
endfor


# Printen allgemeine Form der finalen Interpolationsfunktion

printf('\nInterpolationsfunktion f2:\n\nAllgemein: f2(x) = ')
for s=1:rows(y)
  printf('a%i',(s-1)) #a0, a1, a2, ...
  for(t=1:s-1)
    printf('(x - x%i)',(t)) #Konkaterien eine bestimmte Anzahl an (X-Xi)
  endfor
  if s<rows(y)
    printf(' + ') #Fuegen ein + an
  endif
endfor


# Printen finale Interpolationsfunktion
# Vesion ohne Vektoroperatoren (benoetigen diese nicht, da beim Plotten inline verwendet wird)

f2 = ""; #Erstellen Interpolationsfunktion f2 als String

for s_=1:rows(y)
  #printf('(%f)',n(1,s_))
  f2 = strcat(f2, "(", mat2str(n(1,s_)), ")"); #a0, a1, a2, ...
for(t_=1:s_-1)
  #printf('*(x-(%f))',x(t_))
  f2 = strcat(f2, "*(x-(", mat2str(x(t_)), "))"); #Konkaterien eine bestimmte Anzahl an (X-Xi)
endfor
if s_<rows(y)
  #printf(' + ')
  f2 = strcat(f2, "+"); #Fuegen ein + an
endif
endfor


#{
# Printen finale Interpolationsfunktion
# Vesion mit Vektoroperatoren (falls beim Plotten kein inline verwendet wird)
f2 = "";
  for s_=1:rows(y)
    #printf('(%f)',n(1,s_))
    f2 = strcat(f2, "(", mat2str(n(1,s_)), ")");
  for(t_=1:s_-1)
    #printf('*(x-(%f))',x(t_))
    f2 = strcat(f2, ".*(x.-(", mat2str(x(t_)), "))");
  endfor
  if s_<rows(y)
    #printf(' + ')
    f2 = strcat(f2, ".+");
  endif
endfor
#}

printf('\nFinal: f2(x) = '),disp(f2)


# Evaluieren Interpolationsfunktion aus String

f2_inl = "";
f2_inl = strcat(f2_inl, f2); #Kopieren reine Form der Funktion in f2_inl zum spaeteren Plotten

f2 = strcat("@(x)", f2); #Konvertieren f2 zur anonymen Funktion durch anfuegen von @(x)
f2 = eval(f2); #Evaluieren f2


# Testwerteinsetzung / absolute und relative Fehlerberechnung

printf("\nTestwerteinsetzung / Fehlerberechnung: \n")
printf("\nf(%f) = %f",tw,f(tw))
printf("\nf2(%f) = %f",tw,f2(tw))
abserr = abs(f(tw) - f2(tw)); #Absoluter Fehler
relerr = abserr / f(tw); #Relativer Fehler
printf("\nAbsoluter Fehler: Err(f2(%f)) = %f",tw,abserr)
printf("\nRelativer Fehler: Rel(f2(%f)) = %f (%.2f%%)\n\n",tw,relerr,(relerr*100.0))


# Plotten der Funktionen (in einem Figurefenster)

printf("Plotten Funktionen..\n\n")

# Allgemeine Plotfenstereinstellungen
clf
set(0,'DefaultFigureVisible','on') #Machen Figurefenster sichtbar (umgeht gnuplot Bug)
screensize = get(0, 'screensize'); #Gibt die Bildschirmgroesse zurueck als Vektor
figure('Position',[0 screensize(4) plotw ploth]); #Verschieben Plotfenster und aendern seine Groesse
set(gcf,'name','Newtoninterpolation','numbertitle','off'); #Setzen Fenstertitel

# Plotanzeigebereich (zeigt Region um f(testwert) an)
plotxlo = tw-twspace; #kleinstes x
plotxhi = tw+twspace; #groesstes x
plotylo = f(tw)-twspace; #kleinstes y
plotyhi = f(tw)+twspace; #groesstes y

#{
# Plotanzeigebereich (im Bereich um 0,0)
plotxlo = -5;
plotxhi = 5;
plotylo = -5;
plotyhi = 5;
#}

# Plotten der realen und interpolierten Funktionen
fplot(inline(f_inl), [plotxlo, plotxhi, plotylo, plotyhi]) #Plotten reale funktion f(x) ; blau ist Defaultlinienfarbe
hold on #Behalten die vorher geplottete Funktion ohne zu clearen
fplot(inline(f2_inl), [plotxlo, plotxhi, plotylo, plotyhi], "1") #Plotten interpolierte Funktion f2(x) ; "1" fuer rote Linienfarbe

# Plotten kleine Kreise um die beiden Testwerte in beiden Funktionen
plot(tw,f(tw),'x')
plot(tw,f2(tw),'xr') #Flags: x = zeichnen Kreuz, r = benutzen rote Linienfarbe

# Plotten kleine Kreise um die eingegebenen Punkte
for i = 1:rows(m)
  if x(i) >= plotxlo && x(i) <= plotxhi #Plotten nur die Punkte, welche auf unseren gezeichneten Funktionen zu sehen sind
    plot(x(i),f(x(i)),'o')
    plot(x(i),f2(x(i)),'or')
  endif
endfor

# Zeichnen Linie zwischen f(testwert) und f2(testwert)
line_dx = [tw tw]; #x1, x2
line_dy = [f(tw) f2(tw)]; #y1, y2
line(line_dx, line_dy, 'Color', 'magenta')

# Zeichnen Fehlertext in der Mitte der vorher gezeichneten Linie
msg = "";
#msg = strcat(msg,"f(",mat2str(tw),") = ",mat2str(f(tw)));
#msg = strcat(msg,"f2(",mat2str(tw),") = ",mat2str(f2(tw)));
msg = strcat(msg,"Err(f2(", mat2str(tw) ,")) = ", mat2str(abserr)); 
msg = strcat(msg,"\nRel(f2(", mat2str(tw) ,")) = ",mat2str(relerr)," (",mat2str(round(relerr*10000)/100),"%)");
text(tw,f(tw)+(f2(tw)-f(tw))/2.0,msg,'FontSize', 8);

# Weitere Plotfenstereinstellungen
legend(f_inl,f2_inl); #Printen Legende der Funktionen und Linienfarben
zoom on
grid on
grid minor #Detaillierteres Grid an
xlabel('X')
ylabel('Y')
title('Newtoninterpolation: Vergleich einer eingegebenen (blau) und nach Newton interpolierten (rot) Funktion', 'FontSize', 13) #Titel
hold off
set(0,'DefaultFigureVisible','off') #Machen Figurefenster unsichtbar (umgeht gnuplot Bug)






# ENDE