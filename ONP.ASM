 org 100h

	start:	
	finit
	call ent
	;powitanie
		mov ah,9
		mov dx, wpro
		int 21h
		call ent
	;wprowadzenie dzialania	
		mov ah,10
		mov dx,input
		int 21h
		
	;wyswietlanie dzialania
		mov ah,9
		mov dx, input+2
		int 21h
		call ent
	;wyswietlanie ONP
		mov ah,9
		mov dx, wynonp
		int 21h
		call ent
	;funkcja onp i jej wyswietlanie
		call functionONP
		call wys
		call ent
	;wyswietlanie wyniku
		;mov ah,9
		;mov dx, wyndzi
		;int 21h
		;call ent
	;obliczanie onp i wyswietlanie
		call oblicz
		mov ah,9
		mov dx, input+2
		int 21h
		call ent
		mov ah,2
		mov dx, "="
		int 21h
		call WysWDzie
	;zakonczenie programu
	jmp koniec
	
	
	Niedzielprzez0:
	mov ah,9
	mov dx,nie0
	int 21h
	
	
	
	koniec:	
	mov	ax, 4C00h
	int	21h

input db 25
	  db 0
	  times 26 db "$"
output times 50 db "$"
liczba dw 0
wynik dw 0
clear1 times 30 db 32
liczbaodcz dw 0
spr0 dw 0
l10 dw 10
wpro db "Wprowadz dzialanie:$"
wpro1 db "Wprowadzone dzialanie:$"
wynonp db "Wynik zadzialania funkcji ONP:$"
wyndzi db "Wynik dzialania:$"
nie0 db "Nie dziel przez 0!$"



ent:
	pusha
	pushf
		mov ah,2
		mov dl,10
		int 21h
	popf
	popa
ret

functionONP:



;1.Liczby przesun na wyjscie
;2.Jeżeli nawias otwierajacy to wrzucam na stos operatorów
;3.Jeżeli nawias zamykajacy to sciagam operatory, poki nie pojawi sie nawias otwierajacy, który również sciagam
;4. Nadaje priorytet operatorom operatory Piorytetu1 tj. mnozenie i dzielenie, oraz Priorytetu2 tj. dodawanie i odejmowanie,
;gdy na stosie jest operator wyzszego lub równego priorytetu to sciagam operatory na wyjscie a nastepnie klade obecny operator na stos
;sciagam operatory dopoki stos nie będzie pusty

	pusha
	pushf
	
		mov si,input+2 ; adres zmiennej wejsciowej +2 (2 pierwsze znaki nie są znakami podanymi przez użytkownika)
		mov di,output ; do di przesuwam output, przygotowuje miejsce na wynik operacji
		mov cx,[input+1] ; licznik
		xor ch,ch
		
		petla:
		call OtwN ;sprawdzam czy jest  otwarty nawias
		call ZamN ;sprawdzam czy nawias zamkniety
		call Znak ;sprawdzam czy operator
		call Liczba ; jeśli zadne z powyższych, będe wrzucać liczbe na wyjscie
		
		konpetli:
		inc si
		loop petla
		call CzyscStos ;zdejmuje pozostałe operatory na stosie
		
	popf
	popa
ret
OtwN:
	;Sprawdzam czy jest nawias otwierajacy, jesli tak wwrzucam go na stos i przechodze do nastepnej iteracji,
	; jesli nie ma wracam do miejsca gdzie wywoływałem funkcje
	
		pop bx
		xor ax,ax
		mov al,byte [si]
		cmp al,40
		je OtwNT
		push bx 
		ret
	OtwNT:
		push ax
		jmp konpetli
ZamN: 
;Sprawdzam czy jest zamkniety nawias, jeśli tak, zrzucam operatory ze stosu dopoki nie znajde otwartego nawiasu, który zrzucam po znalezieniu
;ac
		pop bx
		xor ax,ax
		mov al, byte[si]
		cmp al,41
		je ZamNT
		push bx 
		ret
		ZamNT:
		pop ax
		cmp ax,40
		je konpetli
		
			mov [di],ax
			inc di
		jmp ZamNT
		
Znak:
;Sprawdzam po kolei znaki i ich priorytety, gdy na stosie znajduje sie znak o wiekszym lub równego priorytetu to sciagam operatory ze stosu i kłade operator który sprawdzam

	pop bx
	xor ax,ax
	mov al, byte [si]
	 cmp al,43
	 je ZnakP2
	 cmp al,45
	 je ZnakP2
	 cmp al,42
	 je ZnakP1
	 cmp al,47
	 je ZnakP1
	 
	push bx
ret

ZnakP2:
	mov bp,sp
	xor bx,bx
	mov bl,[bp]
	 cmp bl,43
	 je ZnakP2Wyj
	 cmp bl,45
	 je ZnakP2Wyj
	 cmp bl,42
	 je ZnakP2Wyj
	 cmp bl,47
	 je ZnakP2Wyj
	 jmp ZnakKoniec
	 
	ZnakP2Wyj:
	pop bx
	mov [di],bx
	inc di
	jmp ZnakP2
	
ZnakP1:
	mov bp,sp
	xor bx,bx
	mov bl,[bp]
	
		cmp bl,42
		je ZnakP1Wyj
		cmp bl,47
		je ZnakP1Wyj
		jmp ZnakKoniec
	
	ZnakP1Wyj:
	pop bx
	mov [di],bx
	inc di
	jmp ZnakP1
	
	ZnakKoniec:
	push ax
        jmp konpetli

	
Liczba:
;wrzucam na wyjscie dopoki nie znajde znaku innego niz cyfra, wtedy stawiam ';' i koncze wracam do funkcji pierwotnej
	pop bx
	xor ax,ax
	mov al,byte [si]
	mov [di],al
	inc di
	mov al, byte [si+1]
	cmp al,48
	jl dodprze
	cmp al,57
	jg dodprze
	push bx
ret

dodprze:
	mov al,";"
	mov [di],al
	inc di
	push bx
ret




CzyscStos:
	
	;ostatnia procedura ONP, umieszczam na wyjsciu wszystkie operatory które zostały na stosie
	
	pop bx
	
	petla1:
	mov bp,sp
	xor ax,ax
	mov al,[bp]
	cmp al,43
	 je Znaczek
	 cmp al,45
	 je Znaczek
	 cmp al,42
	 je Znaczek
	 cmp al,47
	 je Znaczek
	 
	 push bx
	 ret
	 
	 Znaczek:
	 pop ax
	 mov [di],al
	 inc di
	 jmp petla1
	
wys:

	pusha 
	pushf
		mov ah,9
		mov dl, output
		int 21h
	popf
	popa
ret

oblicz:

;funkcja obliczająca, korzystam z outputu funkcji ONP, przechodze po danych wejsciowych, znalezione liczby (do znaku ';') za pomocą funkcji odczytuje oraz umieszczam na kooprocesorze
; po znalezieniu 2 liczb, zawsze następuje znak działania, wywołuje on odpowiadającą sobie funkcje na kooprocesorze, wynik zostawiam na kooprocesorze i dalej przemieszczam sie po funkcji
;dojscie do znaku "$" kończy działanie funkcji, na koprocesorze pozostaje tylko wynik który wrzucam do zmiennej i wyswietlam.


pusha
pushf

	mov si,output
	
	xor ax,ax
	mov al, byte [si]

	petla4:
	cmp al,";"
	je kondzialania
	cmp al,"+"
	je dod
	cmp al,"-"
	je ode
	cmp al,"/"
	je dzie
	cmp al,"*"
	je mno
	

	jmp liczbaczyt

	kondzialania:
	inc si
	xor ax,ax
	mov al,byte [si]
	cmp al,"$"
	jne petla4
	
	
	fist word [wynik]
	jmp kon

dod:
	faddp
	jmp kondzialania
ode:
	fsubp
	jmp kondzialania
dzie:
	;sprawdzam czy nie nastepuje dzielenie przez 0
	
	xor bx,bx
	fist word [spr0]
	mov bx,[spr0]
	cmp bx,0
	jne skip

	mov ah,9
	mov dx,nie0
	int 21h	
	mov	ax, 4C00h
	int	21h
	
	
	skip:
	fdivp
	jmp kondzialania
mno:
	fmulp
	jmp kondzialania

kon:
popf
popa
ret

liczbaczyt:
	
	;odczytywanie liczby
	;dopoki nie natrafiam na ';' wrzucam na stos cyfry które odczytuje oraz inkrementuje cl by wiedziec ile ich mam
	;gdy trafie na ';', nastepuje zrzucanie wyniki ze stosu, liczby mnoze odpowiednio przez kolejne potegi liczby 10 i dodaje do wyniku
	;przez co tworzę liczbę w zapisie 10
		xor dx,dx
		xor cx,cx
		mov bp,1
		Wrzucajnastos:
		xor ax,ax
		mov al,[si]
		cmp al,";"
		je Zrzucajzestosu
		sub al,48
		push ax
		inc si
		inc cl
		jmp Wrzucajnastos
		
		Zrzucajzestosu:
		pop ax
		mul bp
		add [liczbaodcz],ax
		mov ax,bp
		mov bp,[l10]
		mul bp
		mov bp,ax
		loop Zrzucajzestosu
		
		fild word [liczbaodcz]
		xor ax,ax
		mov ax,0
		mov [liczbaodcz],ax
		jmp kondzialania
		


WysWDzie:
;Wyswietlanie liczby w systemie dziesiętnym

	pusha
	pushf
		mov ax,[wynik]
		mov bx,10
		xor cx,cx
		petla2:
			xor dx,dx
			div bx
			push dx
			inc cl
			cmp ax,0
		jne petla2
		mov ah,2
		petla3:
			pop dx
			add dx,48
			int 21h
			dec cl
			cmp cl,0
		jne petla3
	popf
	popa
ret



clear:
	pusha
	pushf
		mov ah,9
		mov dl, clear1	
		int 21h
		mov ah,2
		mov dl,13
		int 21h
	popf
	popa
ret

