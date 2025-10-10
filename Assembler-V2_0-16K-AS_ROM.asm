;V10 PROMPT, HEXOUT, DELAY, PRINT, TXD, RXD COMMANDS ADDED TO ASSEMBLER
;	-INIT PERIPHERALS IMPROVED
;	-Code start section cleared
;v9 Renamed as Assembler-v2_0-as_ROM.asm
;v9 HEX SAVE CHECKSUM ADDED!
;V8 HEX LOAD CHECKSUM CONTROL ADDED!
;V7 ASSEMBLER BUGS SOLVED! v7 RENAMED AS EFEX V2.0
;Z80 BUFRAM V5: LOOPC FIND IMPROVED FOR SHORT INPUTS 
;v46 ASSEMBLER LACKED COMMAND FAILURE CORRECTED
;  (lokk at LOOPC correction!)
;V45 ASSEMBLER INTEGRATION TO buffer SYSTEM completed!
;v42 SUB AND WARM FUNCTIONS ADDED
;v41 EDIT FUNCTION IMPROVED AND STABILISED
;V40 ADDING BACKSPACE AND FORESPACE
;V39 NEW EDIT WORKING
;V38 NEW EDIT ADDED
;v37 dump modularised (for EDIT command enchancement)
;       -can print single line to edit or view
; STABILE VERSION FOR ALL PREVIOUS ENCHANCEMENTS
;V36    -EDIT:OLD VERSION
;       -MOVE COMMAND ADDED
;       -HELP MENU IMPROVED
;V35 SAVE COMMAND ADDED
;V34 PARSE HEX BYTE ADDED (FOR ONE BYTE INPUTS(FROM BUFFER))
;    -BUFFER EXTENDED
;    -SYSTEM VARIABLES REORGANISED IN TOP OF MEMORY 
;    -FILL COMMAND ADDED
;V33 DISASSEMBLER EXEC ADDED
;V32  -FLEXIBLE ADRESS INPUT ADDED
;     -BUFFER CLEANER ADDED (FOR FALSE HEX PARSING)
;v28 buffer improving by command parsing
;V27 BUF: Buffer added
;V27 Uppercase improved for Turkish İ and ı
;V26  Disassembler improved with table end control
;V25   Print sub improved with 00 ended strings
;V23   Solved some bugs (txt push af)
;V22    UPPERCASE ADDED
;-------------------------------------------------
;Z80 DISASSEMBLER LISTING
;Label  Instruction
;THIS VERSION OF EFEX IS FOR Z80 ONLY. CANNOT RUN ON 8085 !
;-------------------------------------------------

;VERSION HISTORY 

; 8085 V.18; RIM-SIM, 8255 ADDED
; FT245 INTERRUPT CONNECTED TO 8255 PORTB.0
; UNDOCUMENTED 8085 INSTRUCTIONS MOSTLY ADDED
; LXI B,WORD   ; COMMA ADDED AS INTEL MNEMONICS (OLD: LXI B $WORD, NEW: LXI B,$WORD
; PROGRAM MESSAGES IMPROVED
; EFEX 8085 RIM-SIM V0.18 18.JAN.2019


;INTLIN1 TURNED INTO SUBROUTINE
;S-AVE, L-OAD, E-DIT,R-UN,M-OVE COMMANDS ADDED
;EFEX INLINE ASSEMBLER V.087 - 06.APR.2017

;******************************************************************************
;* SİSTEM DEĞİŞKENLERİ (Yeniden Düzenlenmiş ve Word-Aligned) V2.0              *
;* Bellek Haritası: FF00H'dan başlar. Tüm değişkenler 2 byte'a hizalanmıştır.  *
;******************************************************************************

; --- ANA BUFFER'LAR ---
COMINBUF        EQU     0FF00H      ; Ana komut giriş buffer'ı (32 byte)
CODEBUF         EQU     0FF20H      ; Assembler için makine kodu buffer'ı (16 byte)
KEYINBUF        EQU     0FF30H      ; Eski hex giriş için buffer (4 byte)
KEYINRES        EQU     0FF34H      ; Eski hex giriş sonucu (4 byte)

; --- GENEL AMAÇLI VE PARSER DEĞİŞKENLERİ (Tümü 2 Byte) ---
; (FF40H adresinden başlar)
LINELENGHT      EQU     0FF40H      ; COMINBUF'taki komutun uzunluğu
DATAINP         EQU     0FF42H      ; Tek byte'lık hex giriş sonucu
ADRSINP         EQU     0FF44H      ; Çift byte'lık hex giriş sonucu
HEXREG          EQU     0FF46H      ; RUN gibi komutlar için geçici adres
LOWNIBBLE       EQU     0FF48H      ; HEXOUT için geçici düşük nibble
HIGHNIBBLE      EQU     0FF4AH      ; HEXOUT için geçici yüksek nibble

; --- ASSEMBLER DEĞİŞKENLERİ (Tümü 2 Byte) ---
TABFINDAD       EQU     0FF4CH      ; Assembler tablo arama adresi
ASADR           EQU     0FF4EH      ; Mevcut assembly adresi
ASADCODE        EQU     0FF50H      ; Kodu yazılacak assembly adresi
OPBYTECNT       EQU     0FF52H      ; Assembler operand byte sayacı
DIYEZDOLAR      EQU     0FF54H      ; Assembler operand türü (#,$)
CODEBUFLEN      EQU     0FF56H      ; CODEBUF'taki kodun uzunluğu

; --- DISASSEMBLER DEĞİŞKENLERİ (Tümü 2 Byte) ---
DISADDR         EQU     0FF58H      ; Sökülmekte olan adres
DISFINDAD       EQU     0FF5AH      ; Kod tablosunda bulunan adres
DISCODELEN      EQU     0FF5CH      ; Komutun makine kodu uzunluğu
MNESTAD         EQU     0FF5EH      ; Mnemonik başlangıç adresi
MNENDAD         EQU     0FF60H      ; Mnemonik bitiş adresi
OPERAND         EQU     0FF62H      ; Komutun operand adresi
MNELEN          EQU     0FF64H      ; Mnemonik metin uzunluğu
OPCNT           EQU     0FF66H      ; Disassembler operand sayacı

; --- HEX YÜKLEME/KAYDETME DEĞİŞKENLERİ (Tümü 2 Byte) ---
HEXLDREG        EQU     0FF68H      ; Hex load'un ilk adresi kaydedildi mi?
LOADSTADR       EQU     0FF6AH      ; Yüklenen programın başlangıç adresi
SAVECHCK        EQU     0FF6CH      ; Hex save için checksum sayacı

; --- DİĞER SİSTEM İŞARETÇİLERİ (FARKLI BELLEK BÖLGELERİ) ---
; Bu değişkenler çakışmadığı için orijinal yerlerinde bırakılmıştır.
NEXTCODE        EQU     0FF70H      ; Disassembler için sonraki satır adresi
SECTORC         EQU     0FF72H      ; Disassembler ekran satır sayacı
EDITADR         EQU     0FF76H      ; EDIT komutunun mevcut adresi
;INTADRS         EQU     0FF78H      ; Kullanıcı interrupt vektör adresi

STARTADR        EQU     0FF7AH      ;command input variable
ENDADR          EQU     0FF7CH      ;command input variable
COMMVAR         EQU     0FF7EH      ;COMMAND INPUT VARIABLE (2 BYTE)
;------------------------------------------------------------------------
;XXXX           EQU     0FF80H      ; FIRST EMPTY SYSTEM VARIABLE!
INTADRS			EQU		0FF80H 		; NEW INTERRUPT VECTOR
NMIADRS			EQU     0FF82H		; NEW NMI VECTOR


; --- STACK İŞARETÇİSİ ---
; Bu bir değişken alanı değil, sadece bir değerdir. Değişkenlerle çakışmaz.
STACKPOINT      EQU     0FEFFH      ; Yığın (stack) başlangıç noktası
;STACK POINTER;
; -------- UART sabitleri --------
SER_DATA   EQU 00h
SER_STAT   EQU 01h
RXRDY_MASK EQU 02h   ; 8251: bit1 = RxRDY

;****************************************************************
;* 8251A UART SABİT TANIMLAMALARI                 *
;****************************************************************
UART_DATA       EQU     000H    ; 8251 Veri Portu
UART_CTRL       EQU     001H    ; 8251 Kontrol/Durum Portu

; --- Başlatma Komutları ---
UART_CMD_RESET  EQU     040H    ; Dahili Reset Komutu
UART_MODE_WORD  EQU     04EH    ; MODE: 8-bit data, No Parity, 1 Stop Bit, x16 Clock
UART_CMD_WORD   EQU     037H    ; COMMAND: Tx/Rx Enable, Error Reset, RTS/DTR Low


	

;-------------------------------------------------
;8 mhz System clock,1.834 MHz  uart tx/rx clock (DIVIDE BY 16), 32k rom, 32k ram
;PORT 00:UART data, port 01 control/status
;PORT 08:8255    08 input,  09 and 0A output
;
	.org 00000H    ;CHANGE 0000 TO RUN IN ROM!
	;
	JP BASLA
    ;JP GREET
	
;-----------------------------------------------------------------------------------
;   UNCOMMENT THIS TO RUN IN ROM

	.ORG 0038H               ;CHANGEABLE INTERRUPT SUBROUTINE
	LD HL,(INTADRS)
	JP (HL)
	
;-------------------------------------------------------------------------------------

;-----------------------------------------------------------------------------------
;   UNCOMMENT THIS TO RUN IN ROM

	.ORG 0066H               ;CHANGEABLE INTERRUPT SUBROUTINE
	LD HL,(NMIADRS)
	JP (HL)
	
;----------------------------------------------------------------------



	
     .ORG 0100H

BASLA:	
    LD SP,STACKPOINT  ; STACK AT THE END OF  RAM
	LD HL, INPUT;    MA_IN	  ;DEFAULT INTERUPT ROUTINE IS MA_IN PROGRAM
	LD (INTADRS),HL
	IM 1
	DI		;DEFAULT: INTERRUPTS DISABLED


	CALL DE_LAY ;WAIT 500MS FOR PERIPHERALS TO STABILISE.

	CALL INIT8255 ; 82C55 BASE ADRESS : 08H
	CALL INIT8251 ; 8251  BASE ADRESS : 00H
	
	

		
;----------------GREETING MESSAGE----------------------


GREET:
			 ;GREETING  MSG
	LD HL,TABLE
	CALL PRINT


;------------------------NEW MAIN PROGRAM LOOP ----------------------
INPUT:
    CALL PROMPT

    LD HL,COMINBUF
    LD B,01FH 
    LD A,00
INPUT_CLEAR:
    LD (HL),a       ;CLEAR INPUT BUFFER 
    INC HL
    DEC B 
    JP NZ, INPUT_CLEAR
   

    LD HL, COMINBUF ;INPUT BUFFER POINTER
    LD B,01FH      ;MAX 20H CHAR INPUT
    LD A,B
    LD (LINELENGHT),A ;SAVE MAX LENGHT TO REGISTER
INPUT_LOOP:

    CALL RXD
    CALL UPPERCASE 
    CP 0DH          ;FINISH IF CR
    JP Z, PARSER   
    CP 08H          ;BACKSPACE
    JP Z, BCKSPC
   

    CALL TXD        ;ECHO CHAR
    LD (HL),A
    INC HL          ;NEXT CHAR POINTER
    DEC B

    
    JP NZ, INPUT_LOOP ;GET COMMAND TO BUFFER 16 CHAR  LENGHT, TILL CR
    JP PARSER

BCKSPC:
     	;IF BACKSPACE, DELETE LAST CHAR FROM INPUT BUFFER
    LD A, B
    CP 01FH
    JP Z, INPUT_LOOP   ;IF NO CHAR, RETURN TO INPUT

    LD A,08H
    CALL TXD
    LD A,' '
    CALL TXD
    LD A,08H
    CALL TXD
    DEC HL
    INC B
    ;RET
    JP INPUT_LOOP    
;-------------------Command input finished here-----------------

;---------------------------PARSER STARTS HERE-----------------

PARSER: ;PARSE COMMANDS
    ;--- DEĞİŞİKLİK: GERÇEK UZUNLUĞU BURADA HESAPLAYIN ---
    LD A, 01FH     ; B'nin başlangıçtaki maksimum değeri (20H)
    SUB B         ; B'de kalan sayıyı çıkar (15 - kalan = girilen sayı)
    LD (LINELENGHT),A ; Doğru ve net uzunluğu şimdi kaydet
    
   ; CALL PROMPT    ;PARSER'S JOB IS PARSING! NOT PRINTING PROMPT!
    LD HL, COMINBUF
    LD A,(LINELENGHT)
    LD B,A  ;COMMAND LENGHT:B, BUFFER:HL
        ;--- YENİ KORUMA KODU: UZUNLUK SIFIRSA DÖNGÜYÜ ATLA ---
    CP 0          ; A register'ı hala uzunluğu tutuyor, sıfır mı diye bak
    JP Z, INPUT   ; Eğer uzunluk sıfırsa, hiçbir şey basma ve başa dön
                  ; JP Z, PARSER_BITTI gibi temiz bir çıkış noktası da olur.
PARSER_LOOP:    ;COMMAND LENGHT:B, BUFFER:HL
    LD A,(HL)
;-------COMMANDS FIRST CHARS PARSED HERE---------------

    CP 'A'
    JP Z, ASSEMBLE
	CP 'H'
	JP Z, HELP		;HELP SUBROUTINE

    CP '?'
    JP Z, HELPEXEC

    CP 'R'
    JP Z,RUN_ADR		;GO TO ADRESS

    CP 'D'
    JP Z,HEXDUMP		;GO TO ADRESS

    CP 'L'
    JP Z,LOADERZ		;GO TO ADRESS

    CP 'D'
	JP Z, DISASSEMBLER

    CP 'F'
    JP Z, FILL_CMD
    ; ... (diğer komutlar: H, R, D, vs.) ...
    CP 'S'
    JP Z, SAVEX

    CP 'M'
	JP Z, MOVE		;MOVE MEMORY BLOCKS

    CP 'E'
    JP Z, EDIT_CMD   ;MEMORY EDITOR

    CP 'W'
    JP Z, WARMSTART   ;WARMSTART



	






    INC HL
    DEC B
    ;JP NZ, PARSER_LOOP
    JP NZ, ERROR_PARSER
   

    JP INPUT

ERROR_PARSER:
    ; Kırmızı renkli qm basalım

    ; --- 1. Adım: Kırmızı renk kodunu gönder ---
;    LD A, 1BH           ; ESC karakteri
;    CALL TXD
;    LD A, '['           ; CSI karakteri
;    CALL TXD
;    LD A, '3'           ; Parametre '3'
;    CALL TXD
;    LD A, '1'           ; Parametre '1'
;    CALL TXD
;    LD A, 'm'           ; Komut karakteri 'm'
;    CALL TXD

    ; --- 2. Adım: Asıl metni gönder ---
    LD A, '?'  ;HATALI KOMUT
    CALL TXD

    ; --- 3. Adım: Rengi sıfırla (ÇOK ÖNEMLİ!) ---
 ;   LD A, 1BH           ; ESC karakteri
 ;   CALL TXD
 ;   LD A, '['           ; CSI karakteri
 ;   CALL TXD
 ;   LD A, '0'           ; Sıfırlama parametresi '0'
 ;   CALL TXD
 ;   LD A, 'm'           ; Komut karakteri 'm'
 ;   CALL TXD
; Veya MAVİ BEYAZ PEKER TARZI; 
; ... (Kırmızı renk ayarlanır ve "HATA!" yazılır) ...

; --- 3. Adım: Rengi NORMALE (Beyaz/Mavi) döndür ---
;    LD A, 1BH           ; ESC
;    CALL TXD
;    LD A, '['
;    CALL TXD
;    LD A, '3'           ; Beyaz yazı parametresi (37)
;    CALL TXD
;    LD A, '7'
;    CALL TXD
;    LD A, ';'           ; Parametre ayırıcı
;    CALL TXD
;    LD A, '4'           ; Mavi zemin parametresi (44)
;    CALL TXD
;    LD A, '4'
;    CALL TXD
;    LD A, 'm'
;    CALL TXD




    JP INPUT

;****************************************************************
;* PARSE_HEX_CHAR ALT PROGRAMI                                  *
;* Açıklama: HL'nin gösterdiği adresteki karakteri okur. Eğer   *
;* karakter geçerli bir hex ise, 4-bitlik değerini A'ya yazar,  *
;* HL'yi bir artırır ve Carry=0 ile döner. Geçersizse,          *
;* Carry=1 ile döner.                                           *
;* Girdi: HL = Buffer içindeki karakterin adresi                *
;* Çıktı: Başarılıysa -> Carry=0, A=Sayısal değer (0-15), HL artırılmış*
;* Başarısızsa -> Carry=1, A=Karakterin ASCII kodu, HL aynı*
;****************************************************************
PARSE_HEX_CHAR:
    LD A, (HL)          ; Buffer'dan karakteri oku
    CALL UPPERCASE      ; Kontrol kolaylığı için büyük harfe çevir

    ; --- DOĞRULAMA KISMI ---
    CP '0'
    JP C, NOT_A_HEX     ; '0'dan küçükse geçersiz
    CP '9' + 1
    JP C, CONVERT_DIGIT ; '9'dan büyük değilse, bu bir rakamdır

    CP 'A'
    JP C, NOT_A_HEX     ; 'A'dan küçükse geçersiz
    CP 'F' + 1
    JP NC, NOT_A_HEX    ; 'F'den büyükse geçersiz
    
    ; Karakter 'A'-'F' aralığındadır
    JP CONVERT_LETTER

CONVERT_DIGIT:
    SUB '0'             ; ASCII değerini sayısal değere çevir
    JP CONVERSION_OK

CONVERT_LETTER:
    SUB 'A'             ; 'A'->0, 'B'->1, ...
    ADD A, 10           ; Doğru sayısal değeri bulmak için 10 ekle

CONVERSION_OK:
    INC HL              ; Başarılı, buffer işaretçisini bir sonraki karaktere ilerlet
    OR A                ; Carry bayrağını temizle (başarı sinyali)
    RET

NOT_A_HEX:
    SCF                 ; Carry bayrağını set et (hata sinyali)
    RET    
;------------hex to byte from buffer ended------------------------------------

;******************************************************************************
;* PARSE_HEX_ADDRESS (Sıfırdan Yazılmış Nihai Versiyon)                       *
;* Açıklama: HL'nin gösterdiği yerden 1-4 haneli hex adresi okur.            *
;* Sonucu sağa dayalı olarak hesaplar (Örn: "F" -> 000FH, "1F4" -> 01F4H).     *
;* Girdi: HL = Ana buffer'da adresin başladığı yer                            *
;* Çıktı: Başarılıysa -> Carry=0, DE=16-bit adres, HL=sayıdan sonraki karakter *
;* Başarısızsa -> Carry=1 (hiç hex karakter bulunamadıysa)             *
;******************************************************************************
PARSE_HEX_ADDRESS:
    LD DE, 0          ; 1. Sonuç register'ı (DE) her zaman SIFIRDAN başlar.
    LD B, 4           ; 2. En fazla 4 hane okumak için sayaç.

PARSE_LOOP_FINAL:
    LD A, B
    CP 0
    JP Z, PARSE_EXIT_FINAL ; Sayaç bittiyse (4 hane okunduysa) çık.

    LD A, (HL)        ; Buffer'dan sıradaki karakteri oku.

    ; --- KARAKTERİ DOĞRUDAN İÇERİDE ÇEVİR VE KONTROL ET ---
    CALL UPPERCASE      ; 'a'-'f' ise 'A'-'F' yap.
    PUSH DE             ; Ara sonucu (DE) ve sayacı (B) koru.
    PUSH BC
    
    ; Gelen karakterin (A) sayısal değerini (0-15) bulalım.
    SUB '0'
    JP C, NOT_HEX_FINAL ; '0'dan küçükse hex değildir.
    CP 10
    JP C, IS_VALID_HEX  ; 0-9 arasındaysa geçerlidir.
    
    LD A, (HL)          ; Karakteri tekrar yükle (çünkü SUB '0' ile bozuldu)
    CALL UPPERCASE
    SUB 'A'
    JP C, NOT_HEX_FINAL ; 'A'dan küçükse hex değildir.
    CP 6                ; 'F'-'A' = 5. 6'dan büyük veya eşitse geçersiz.
    JP NC, NOT_HEX_FINAL
    ADD A, 10           ; 'A'-'F' ise 10-15 arası değere çevir.

IS_VALID_HEX:
    ; Başarılı: A register'ı 0-15 arası doğru değeri içeriyor.
    POP BC              ; Sayaçları geri al.
    POP DE              ; Ara sonucu geri al.

    ; --- BASİTLEŞTİRİLMİŞ "KAYDIR VE EKLE" ---
    ; a) Mevcut sonucu (DE) 16 ile çarp.
    PUSH HL             ; Buffer işaretçisi HL'yi KORU!
    LD HL, DE
    ADD HL, HL          ; HL = HL * 2
    ADD HL, HL          ; HL = HL * 4
    ADD HL, HL          ; HL = HL * 8
    ADD HL, HL          ; HL = HL * 16
    
    ; b) Yeni haneyi ekle.
    LD E, A             ; Yeni haneyi (0-15) E'ye koy.
    LD D, 0             ; D'yi sıfırla.
    ADD HL, DE          ; HL = (Eski Sonuç * 16) + Yeni Hane
    LD DE, HL           ; Nihai sonucu DE'ye geri al.
    POP HL              ; Buffer işaretçisi HL'yi GERİ YÜKLE!
    
    INC HL              ; Ana buffer'da bir sonraki karaktere geç.
    DEC B               ; Kalan hane hakkını azalt.
    JP PARSE_LOOP_FINAL ; Döngüye devam et.

NOT_HEX_FINAL:
    ; Başarısız: Karakter hex değil, sayı bitti demektir.
    POP BC              ; Stack'i düzeltmek için register'ları geri al.
    POP DE
    ; Kasıtlı olarak döngüden çıkmak için PARSE_EXIT_FINAL'a atla.

PARSE_EXIT_FINAL:
    ; Okunan hane sayısını bul: 4 - B'de kalan sayı
    LD A, 4
    SUB B
    CP 0
    JP Z, PARSE_ERROR_FINAL ; Hiç hane okunmadıysa hata.

    OR A                ; Başarı sinyali (Carry=0).
    RET

PARSE_ERROR_FINAL:
    SCF                 ; Hata sinyali (Carry=1).
    RET
;----------------ADRESS PARSER (FROM BUFFER) ENDED-----------------  


;******************************************************************************
;* PARSE_HEX_BYTE (YENİ, GÜVENLİ ve BASİT Versiyon)                           *
;* Açıklama: HL'nin gösterdiği yerden 1 veya 2 haneli hex sayıyı okur.        *
;* Kendi içinde PUSH/POP kullanmadığı için yığını bozmaz.                     *
;* Girdi: HL = Ana buffer'da sayının başladığı yer                            *
;* Çıktı: Başarılıysa -> Carry=0, A=8-bit değer, HL=sayıdan sonraki karakter   *
;* Başarısızsa -> Carry=1 (hiç hex karakter bulunamadıysa)               *
;******************************************************************************
PARSE_HEX_BYTE:
    ; --- İlk haneyi okumayı dene ---
    CALL PARSE_HEX_CHAR
    JP C, PARSE_BYTE_ERROR   ; Hiç hane yoksa doğrudan hata ver.

    LD B, A                  ; İlk hanenin değerini (0-15) B'de sakla.
                             ; HL, PARSE_HEX_CHAR tarafından ilerletildi.
    
    ; --- İkinci haneyi okumayı dene ---
    ; NOT: HL zaten bir sonraki karakteri gösteriyor.
    CALL PARSE_HEX_CHAR
    
    ; Eğer ikinci karakter hex değilse (Carry=1 ise), sonuç tek hanelidir.
    JP C, PARSE_BYTE_DONE_1

    ; --- İki hane de bulundu. A'da ikinci hane, B'de ilk hane var. Birleştir. ---
    LD C, A                  ; İkinci haneyi C'de sakla.
    LD A, B                  ; Birinci haneyi A'ya al.
    ADD A, A                 ; A = A * 2
    ADD A, A                 ; A = A * 4
    ADD A, A                 ; A = A * 8
    ADD A, A                 ; A = A * 16
    ADD A, C                 ; A = (Birinci hane * 16) + İkinci hane
    JP PARSE_BYTE_DONE_2

PARSE_BYTE_DONE_1:
    ; Sonuç tek haneli. Değer zaten B'deydi.
    LD A, B
PARSE_BYTE_DONE_2:
    OR A                     ; Başarı sinyali (Carry=0).
    RET

PARSE_BYTE_ERROR:
    SCF                      ; Hata sinyali (Carry=1).
    RET




;-----------------hex byte parsing ended here----------------------
CRLF: 
    LD A,0AH
    CALL TXD
    LD A,0DH
    CALL TXD
    RET


PROMPT:	
    ; Yeşil  renkli prompt basalım

    ; --- 1. Adım: Kırmızı renk kodunu gönder ---
;    LD A, 1BH           ; ESC karakteri
;    CALL TXD
;    LD A, '['           ; CSI karakteri
;    CALL TXD
;    LD A, '3'           ; Parametre '3'
;    CALL TXD
;    LD A, '2'           ; Parametre '1'
;    CALL TXD
;    LD A, 'm'           ; Komut karakteri 'm'
;    CALL TXD

    ; --- 2. Adım: Asıl metni gönder ---
    LD HL,TABLE6 
	CALL PRINT

    ; --- 3. Adım: Rengi sıfırla (ÇOK ÖNEMLİ!) ---
;    LD A, 1BH           ; ESC karakteri
;    CALL TXD
;    LD A, '['           ; CSI karakteri
;    CALL TXD
;    LD A, '0'           ; Sıfırlama parametresi '0'
;    CALL TXD
;    LD A, 'm'           ; Komut karakteri 'm'
;    CALL TXD

; ... (Kırmızı renk ayarlanır ve "HATA!" yazılır) ...

; --- 3. Adım: Rengi NORMALE (Beyaz/Mavi) döndür ---
;    LD A, 1BH           ; ESC
;    CALL TXD
;    LD A, '['
;    CALL TXD
;    LD A, '3'           ; Beyaz yazı parametresi (37)
;    CALL TXD
;    LD A, '7'
;    CALL TXD
;    LD A, ';'           ; Parametre ayırıcı
;    CALL TXD
;    LD A, '4'           ; Mavi zemin parametresi (44)
;    CALL TXD
;    LD A, '4'
;    CALL TXD
;    LD A, 'm'
;    CALL TXD

	RET

;UPPERCASE:     ;international keyboard   

;                CP 'a'            ; A 'a'dan küçük mü?
;                JP C, DONEUP       ; Evetse, atla
;                CP 'z'+1          ; A 'z'den büyük mü?
;                JP NC, DONEUP       ; Hayırsa, atla
;                SUB 0x20          ; Küçük harfse büyük harfe dönüştür
;DONEUP:           RET               ; İşlemi bitir   
	
UPPERCASE:
    ; --- Adım 1: Türkçe 'ı' (noktasız i) için özel kontrol ---
    CP      0FDH            ; Karakter 'ı' mı?
    JP      NZ, KONTROL_I_BUYUK ; Değilse, sonraki kontrole git
    LD      A, 'I'          ; Evetse, 'I' yap
    JP      DONEUP          ; Ve çık

KONTROL_I_BUYUK:
    ; --- Adım 2: Türkçe 'İ' (büyük i) için özel kontrol ---
    ; Shift/CapsLock ile 'i'ye basıldığında bu karakter gelir
    CP      0DDH            ; Karakter 'İ' mi?
    JP      NZ, KONTROL_STD ; Değilse, standart kontrole git
    LD      A, 'I'          ; Evetse, bunu da standart 'I' yap
    JP      DONEUP          ; Ve çık

KONTROL_STD:
    ; --- Adım 3: Standart 'a'-'z' aralığını kontrol et ---
    CP      'a'
    ; 'a'dan küçükse (A-Z, 0-9, vs) dokunma Bu, 'I' harfinin de
    ; değişmeden kalmasını sağlar
    JP      C, DONEUP
    CP      'z' + 1
    ; 'z'den büyükse (diğer özel karakterler) dokunma
    JP      NC, DONEUP
    
    ; --- Adım 4: Güvenli çevirme işlemi ---
    ; Bu aralık küçük 'i' harfini içerir ve onu 'I' harfine dönüştürür
    SUB     020H

DONEUP:
    RET    
	




;----------------HELP-------------------------
HELP:
    INC HL
    DEC B ; H RECEIVED, SO DECREASE POINTER AND COUNTER
    LD A,(HL)
    CP 'E'
    JP NZ, ERROR_PARSER
    INC HL
    DEC B ; E RECEIVED, SO DECREASE POINTER AND COUNTER
    LD A,(HL)
    CP 'L'
    JP NZ, ERROR_PARSER
    INC HL
    DEC B ; L RECEIVED, SO DECREASE POINTER AND COUNTER
    LD A,(HL)
    CP 'P'
    JP NZ, ERROR_PARSER
    JP HELPEXEC

HELPEXEC:	             ;HELP MSG
	LD HL,TABLE21
	CALL PRINT
	
	
	JP INPUT
    ;JP MA_IN
	

	

	
;--------------DELAY 500MS---------------	
DE_LAY:
	
	PUSH DE
	PUSH AF
	LD DE,0FF00H
DISDELAY:
	DEC DE
	LD A,D
	OR E
	JP NZ,DISDELAY
	POP DE
	POP AF
	RET
;--------------------------------------	
;--------------DELAY 1S----------------
DELAY_1S:
	CALL DE_LAY
	CALL DE_LAY
	RET
;--------------------------------------

;---------PRINT SUBROUTINE-------------

	
PRINT:	LD A,(HL)
		CP 0
		JP Z,PRINTDONE
		CALL TXD
		INC HL
		JP NZ,PRINT
PRINTDONE:		
		RET
;--------------------------------------	

;----------------INIT-8255----------------------------------

	INIT8255:	;8255 @PORT 018H-01BH  ; 8255 BASE ADRESS: 08H

    CALL DE_LAY ;WAIT 500MS FOR 8255 TO RESET
	LD A,092H
	OUT (0BH),A 	;A(08H) AND B(09H)  C(0AH)  CONTROL: OBH
	
	;9B: A,B,C ALL INPUT
	;90: A INPUT, B AND C OUTPUT
	;80: A,B,C ALL OUTPUT
	;92: A AND B INPUT, C OUTPUT
	;82: A OUTPUT, B INPUT, C OUTPUT
    RET

    
;----------------INIT-8251----------------------------------







;****************************************************************
;* INIT8251 - 8251A UART Başlatma Rutini                        *
;* Açıklama: Bu rutin, 8251A'yı güvenilir bir şekilde başlatır,  *
;* senkronize eder ve standart 8-N-1 modunda çalışmaya hazırlar.*
;****************************************************************
INIT8251:
    ;; Adım 1: Senkronizasyon (Sync)
    ;; 8251'in hangi modda olduğundan emin olmak için, önce üç kez
    ;; 00h göndererek komut moduna girmeye zorlanır. Bu, tekrarlanan
    ;; 40h göndermekten daha güvenilir bir yöntemdir.
    LD A, 00H
    OUT (UART_CTRL), A ;FORCED COMMAND MODE
    NOP
    OUT (UART_CTRL), A
    NOP
    OUT (UART_CTRL), A
    NOP

    ;; Adım 2: Dahili Reset (Internal Reset)
    ;; Senkronizasyon sonrası, 40h komutu ile entegrenin iç durumu
    ;; temizlenir ve Mod kelimesini almaya hazırlanır.
    LD A, UART_CMD_RESET ;40H
    OUT (UART_CTRL), A
    NOP
    NOP

    ;; Adım 3: Mod Kelimesinin Yazılması (Mode Word)
    ;; UART'ın temel çalışma parametreleri ayarlanır.
    LD A, UART_MODE_WORD ;04EH
    OUT (UART_CTRL), A
    NOP
    NOP

    ;; Adım 4: Komut Kelimesinin Yazılması (Command Word)
    ;; Alıcı (Rx) ve verici (Tx) aktif edilir, hata bayrakları sıfırlanır.
    LD A, UART_CMD_WORD  ;037H
    OUT (UART_CTRL), A

    RET
  
	
      

	

;-------------HEXDUMP--------------------------
;HEXDUMP OF INPUTTED MEMORY- +FFH

	
HEXDUMP:
    ;----------------------------------------------------
    ; 1. "DUMP <adres>" komutunu ve adresi ayrıştıran bölüm
    ;----------------------------------------------------
    INC HL
    DEC B       ; 'D' karakterini atla
    LD A, (HL)
    CP 'U'
    JP NZ ,FROM_HEXDUMP
    INC HL
    DEC B       ; 'U' karakterini atla
    LD A, (HL)
    CP 'M'
    JP NZ, ERROR_PARSER
    INC HL
    DEC B       ; 'M' karakterini atla
    LD A, (HL)
    CP 'P'
    JP NZ, ERROR_PARSER
    INC HL
    DEC B       ; 'P' karakterini atla

    CALL SKIP_SPACES
    CALL PARSE_HEX_ADDRESS
    JP C, ERROR_PARSER
    LD HL, DE   ; Başarılı! Dump başlangıç adresi HL'ye alındı.

    ;-----------------------------------------------------------------
    ; 2. YENİ ve BASİT GÖRÜNTÜLEME DÖNGÜSÜ (Eskisiyle değiştirildi)
    ;-----------------------------------------------------------------
DUMP_PAGE_LOOP:
    LD DE, 16           ; Ekrana 16 satır bas
DUMP_LINE_LOOP:
    CALL DRAW_DUMP_LINE ; Bir satırı çizmesi için alt programı çağır
    DEC DE
    LD A, D
    OR E
    JP NZ, DUMP_LINE_LOOP

    ;------------------------------------------------------------------
    ; 3. TUŞ BEKLEME BÖLÜMÜ (Bu blok zaten vardı ve korundu)
    ;------------------------------------------------------------------   
	
CIKIS:	
    CALL RXD
	CP 01BH
	JP Z,INPUT		;ESC : EXIT TO MAIN MENU
	CP 0DH
	JP Z, DUMP_PAGE_LOOP		;ENTER OR SPACE CONT. TO LISTING
	CP 020H
	JP Z, DUMP_PAGE_LOOP
	JP CIKIS
;******************************************************************************
;* DRAW_DUMP_LINE ALT PROGRAMI                                                *
;* Açıklama: HL'nin gösterdiği adresten başlayarak tam bir hexdump satırı çizer.*
;* Girdi: HL = Basılacak satırın başlangıç adresi                             *
;* Çıktı: HL = Bir sonraki satırın adresi (HL + 16)                           *
;* Korur: AF, BC, DE                                                          *
;******************************************************************************
DRAW_DUMP_LINE:
    PUSH AF             ; Kullanılacak register'ları korumaya al
    PUSH BC
    PUSH DE

    ; --- Satır başı ve Adres basımı ---
    LD A, 0DH           ; Enter
    CALL TXD
    LD A, 0AH
    CALL TXD
    LD A, H             ; Adresin yüksek byte'ını bas
    CALL HEXOUT
    LD A, L             ; Adresin düşük byte'ını bas
    CALL HEXOUT
    LD A, ':'
    CALL TXD
    LD A, ' '
    CALL TXD

    ; --- Hex dökümünü bas (16 byte) ---
    LD B, 8             ; İlk 8 byte
DRAW_HEX1:
    LD A, (HL)
    CALL HEXOUT
    LD A, ' '
    CALL TXD
    INC HL
    DEC B
    JP NZ, DRAW_HEX1
    
    LD A, ' '           ; Ara boşluk
    CALL TXD
    LD A, ' '
    CALL TXD
    
    LD B, 8             ; Sonraki 8 byte
DRAW_HEX2:
    LD A, (HL)
    CALL HEXOUT
    LD A, ' '
    CALL TXD
    INC HL
    DEC B
    JP NZ, DRAW_HEX2
    
    ; Bu noktada HL, satırın sonunu (başlangıç + 16) gösteriyor.

    ; --- ASCII dökümünü bas ---
    LD A, ' '           ; Ayraç bas
    CALL TXD
    ;LD A, '|'
    ;CALL TXD
    LD A, ' '
    CALL TXD

    ; ASCII basımı için HL'yi 16 byte geri sar
    PUSH AF             ; Geri sarma işlemi için AF'yi koru
    LD A, L
    SUB 10H
    LD L, A
    JP NC, NO_CARRY_SUB_DRAW
    DEC H
NO_CARRY_SUB_DRAW:
    POP AF

    ; 16 byte'ı karakter olarak bas
    LD B, 16
DRAW_ASCII_LOOP:
    LD A, (HL)
    CP 20H              ; Basılabilir karakter mi?
    JP C, DRAW_DOT
    CP 7FH
    JP NC, DRAW_DOT
    CALL TXD            ; Evet, kendisini bas
    JP CHAR_DRAWN
DRAW_DOT:
    LD A, '.'           ; Hayır, nokta bas
    CALL TXD
CHAR_DRAWN:
    INC HL
    DEC B
    JP NZ, DRAW_ASCII_LOOP
    
    ; Bu noktada HL, tekrar satırın sonunu (başlangıç + 16) gösteriyor.
    
    POP DE              ; Korunan register'ları geri yükle
    POP BC
    POP AF
    RET	

	
;-----DUMP COMMAND ENDED HERE---------------------------------------------

;---------------efex-ASSEMBLER---v0.87beta-STARTS HERE---------------
;                                                                    |
;                      A  S  S  E  M  B  L  E  R                     |
;                                                                    |
;                       BACKSPACE WORKS IN TEXT                      |
;                     NO BACKSPACE AFTER # OR $                      |
;                         SYNTAX CHECK ADDED                         |
;                                                                    |
;--------------------------------------------------------------------
;INPUT ASSEMBLER ADRESS-------

ASSEMBLE:
    INC HL
    DEC B       ; 'A' karakterini atla

    LD A, (HL)
    CP 'S'
    JP NZ, ERROR_PARSER
    INC HL
    DEC B       ; 'S' karakterini atla

    LD A, (HL)
    CP 'M'
    JP NZ, ERROR_PARSER
    INC HL
    DEC B       ; 'M' karakterini atla

    ; Boşluk ve $ işaretlerini atlayan yardımcı rutini çağır
    CALL SKIP_SPACES

    ; 1-4 haneli hex adresi okuyup 16-bit'e çeviren ana rutini çağır
    CALL PARSE_HEX_ADDRESS
    JP C, ERROR_PARSER    ; Hata varsa (hiç hex karakter bulunamadıysa) çık

    ; Başarılı! 16-bitlik adres DE register'ında hazır.
    LD HL, DE             ; Çalıştırılacak adresi HL'ye al
    ;JP (HL)               ; Adrese zıpla!
    LD (ADRSINP),HL       ; SAVE DISASSEMBLER ADRESS TO 
	
	


	LD HL,TABLE_ASS ;ASSEMBLER MESSAGE
	CALL PRINT
	
	
	LD HL, (ADRSINP)
	LD (ASADR),HL       ;ASSEMBLY TARGET ADRESS
	
	
	LD A, 0DH
	CALL TXD
	LD A, 0AH
	CALL TXD
	
	
;---------------main assembler loop start here------------	
	
AS_DON:	


;===========================================================
; AS_PARSER — AS_DON ile INTERPRET arasına eklenecek
; 1) COMINBUF'u 0x1F temizler, DATAINP/ADRSINP/DIYEZDOLAR'ı sıfırlar
; 2) 0x1F'e kadar satır okur (CR=0Dh ile biter), BACKSPACE=08h destekli
; 3) Taramada:
;    - '#' görülürse parse_hex_byte çağrılır; başarılı ise 2 haneyi SİLER,
;      A'yı DATAINP'e yazar, DIYEZDOLAR='#' yapar.
;    - '$' görülürse parse_hex_adress çağrılır; başarılı ise 4 haneyi SİLER,
;      adresi ADRSINP (low,high) yazar, DIYEZDOLAR='$' yapar.
;    - IM1 gibi komutlardaki rakamlar KORUNUR (sadece #/$ sonrası haneyi siler).
; 4) LINELENGHT'i (DE-COMINBUF) yazar ve INTERPRET'e geçer.
; Not: parse_hex_byte ve parse_hex_adress mevcut kodundaki imzalarıyla kullanılmaktadır.
;===========================================================

;---------------main assembler loop start here------------	
	
AS_DON:	
;---------------main assembler loop start here------------	
	
;---------------main assembler loop start here------------	
	
AS_DON:	
;******************************************************************************
;* NİHAİ DÜZELTME v4.0 - (HL OKUMA İŞARETÇİSİ KORUMA HATASI GİDERİLDİ)         *
;* Açıklama: Bu versiyon, $ operandı işlenirken hem yazma işaretçisi DE'nin,  *
;* hem de okuma işaretçisi HL'nin stack kullanılarak doğru şekilde korunmasını *
;* ve geri yüklenmesini sağlayarak önceki hatayı düzeltir.                    *
;******************************************************************************

    ; --- Adım 1: Buffer ve değişkenleri temizle ---
    XOR A
    LD (DIYEZDOLAR), A      
    LD (DATAINP), A         
    LD HL, 0
    LD (ADRSINP), HL        
    
    LD HL, COMINBUF
    LD B, 32                
AS_CLEAR_LOOP:
    LD (HL), 0
    INC HL
    DEC B
    JP NZ, AS_CLEAR_LOOP

    ; --- Adım 2: Komut satırını buffer'a al ---
    CALL CRLF
    LD HL, (ASADR)
    LD A, H
    CALL HEXOUT
    LD A, L
    CALL HEXOUT
    LD A, '>'
    CALL TXD
    LD A, ' '
    CALL TXD

    LD HL, COMINBUF
    LD B, 31                
AS_INPUT_LOOP:
    CALL RXD
    CALL UPPERCASE
    CP 1BH
    JP Z, INPUT             
    CP 0DH                  
    JP Z, AS_PARSE_START
    CP 08H                  
    JP Z, AS_BCKSPC

    CALL TXD                
    LD (HL), A
    INC HL
    DEC B
    JP NZ, AS_INPUT_LOOP
    JP AS_PARSE_START       

AS_BCKSPC:
    LD A, B
    CP 31
    JP Z, AS_INPUT_LOOP     
    
    LD A, 08H
    CALL TXD
    LD A, ' '
    CALL TXD
    LD A, 08H
    CALL TXD
    
    DEC HL
    LD (HL), 0              
    INC B
    JP AS_INPUT_LOOP

AS_PARSE_START:
    LD (HL), 0

    ; --- Adım 3: Buffer'ı işle, sayıları ayır, rakamları sil ---
    LD HL, COMINBUF         
    LD DE, COMINBUF         

SCAN_AND_COPY_LOOP:
    LD A, (HL)
    CP 0                    
    JP Z, SCAN_FINISHED

    CP '#'
    JP Z, HANDLE_SYMBOL
    
    CP '$'
    JP Z, HANDLE_SYMBOL

    LD (DE), A
    INC HL
    INC DE
    JP SCAN_AND_COPY_LOOP

HANDLE_SYMBOL:
    LD (DE), A
    INC DE
    LD (DIYEZDOLAR), A
    INC HL
    
    CP '#'
    JP Z, PARSE_THE_BYTE
    
    ; --- $ OPERANDI İÇİN HL VE DE KORUMALI NİHAİ BLOK ---
    PUSH DE                 ; 1. Yazma işaretçisini (DE) korumaya al.
    PUSH HL                 ; 2. Okuma işaretçisini (HL) korumaya al.
    
    CALL PARSE_HEX_ADDRESS  ; 3. Adresi ayrıştır. Sonuç DE'de, HL ilerletildi.
    JP C, PARSE_ERROR_FIX_STACK ; Hata varsa stack'i düzelterek çık.
    
    EX DE, HL               ; 4. Sonucu (adresi) DE'den HL'ye taşı.
    LD (ADRSINP), HL        ; 5. Adresi HL üzerinden ilgili değişkene kaydet.
    
    POP HL                  ; 6. Orijinal okuma işaretçisini geri yükle.
    POP DE                  ; 7. Orijinal yazma işaretçisini geri yükle.
    
    ; NOT: PARSE_HEX_ADDRESS HL'yi zaten ilerlettiği için, stack'ten
    ; eski HL'yi geri almak yerine ilerlemiş HL'yi kullanmalıyız.
    ; Dolayısıyla kodun en doğru hali aşağıdaki gibidir:
    
    ; TEKRAR DÜZELTME: EN DOĞRU VE BASİT YÖNTEM
    PUSH DE                 ; 1. YAZMA İŞARETÇİSİNİ (DE) KORU
    CALL PARSE_HEX_ADDRESS  ; 2. ÇAĞRIYI YAP. HL İLERLEDİ, DE SONUCU TUTUYOR.
    JP C, PARSE_ERROR_FIX_STACK
    PUSH HL                 ; 3. İLERLEMİŞ OKUMA İŞARETÇİSİNİ (HL) KORU
    LD HL, DE               ; 4. SONUCU (DE) KAYDETMEK İÇİN GEÇİCİ OLARAK HL'YE AL
    LD (ADRSINP), HL        ; 5. SONUCU DEĞİŞKENE KAYDET
    POP HL                  ; 6. İLERLEMİŞ OKUMA İŞARETÇİSİNİ GERİ AL
    POP DE                  ; 7. YAZMA İŞARETÇİSİNİ GERİ AL
    JP SCAN_AND_COPY_LOOP   ; 8. HER İKİ İŞARETÇİ DE DOĞRU YERDE, DEVAM ET.

PARSE_THE_BYTE:
    CALL PARSE_HEX_BYTE
    JP C, AS_SYNTAX_ERROR   
    LD (DATAINP), A         
    JP SCAN_AND_COPY_LOOP   

SCAN_FINISHED:
    LD (DE), A
    EX DE, HL               
    LD DE, COMINBUF
    OR A                    
    SBC HL, DE              
    LD (LINELENGHT), HL     
    JP INTERPRET            

PARSE_ERROR_FIX_STACK:
    POP HL                  ; Stack'i dengelemek için HL'yi de POP et
    POP DE                  
AS_SYNTAX_ERROR:
    LD HL, ERROR            
    CALL PRINT
    JP AS_DON               


;---------------INTERPRETER STARTS HERE--------------------------







	
;--------LINE INPUT FINISHED HERE----- 
;------------------------------------------------------------------------
;            	                                                         |
;	RESULT: Mnemonic string in COMINBUF (INPUT BUFFER)               |
;         Mnemonic lenght in LINELENGHT  (for use Register BC)           |
;        if operand=$: result in ADRSINP-FF43H FF44h                     |
;	 if operand=#: result in DATAINP-FF42                            |
;		                                                         |
;-------------------------------------------------------------------------	
	
		 
;---------------INTERPRETER STARTS HERE--------------------------
;Interpreter translates input buffer mnemonics to machine code
;
;            SYSTEM VARIABLES OF INTERPRETER
;
;
;FF60-FF6F  :COMMAND INPUT BUFFER
;FFA0-FFA1  :COMMAND LINE LENGHT TO BE TRANSLATED
;FF80-FF90  :CODE BUFFER----
;FFA2-FFA3  :MNEMONIC TABLE FFINDED INDEX ADRESS
;FFA4-FFA5  :ASSEMBLY ADRESS
;FFA6-FFA7  :ASSEMBLY ADRES + CODES TO WRITE MEMORY
;FFB0	    :OPERAND BYTE COUNT
;FFB2	    : # OR $ OR NULL
;FF42       :# CONTENT (DATA)
;FF43-FF44  :$ CONTENT (ADRESS)
;FFB3-FFB4  :CODE BUF. LENGHT	

INTERPRET:		;ASSEMBLER INTERPRETER
	CALL FINDCOM	;FIND MNEMONIC FROM TABLE
	
	LD A,' '
	CALL TXD
	LD A,' '
	CALL TXD
	
	
	
	LD DE,CODEBUF	;CODE BUFFER
	LD HL,(TABFINDAD) 	;MNEMONIC ADRESS FROM TABLE (HOLDS BYTE COUNT AT THE MOMENT)
			
		
	LD A,(HL)	;OPERAND COUNT
	LD B,A
	LD C,0 	; CODE COUNT RESET

	
	INC HL		;HL AT FIRST OPERAND ADRESS(COMMAND)
DISIN:	LD A,(HL) 	;TAKE COMMAND 
	LD (DE),A	;WRITE TO CODE BUFFER
	INC HL
	INC DE
	INC C
	DJNZ DISIN
	
	LD A,(DIYEZDOLAR)
	CP '#'
	CALL Z, DIYEZ1
	CP '$'
	CALL Z, DOLLAR1
	
	LD A,C
	LD (CODEBUFLEN),A    ;CODE LENGHT
	

	LD A,(DIYEZDOLAR)  	;JUST OUTPUT COMPOSER TO GOOD VIEW
	CP 0
	JP NZ, UZUN
	LD A,' '
	CALL TXD	
	LD A,' '
	CALL TXD
	LD A,009H
	CALL TXD

UZUN:	LD A,' '
	CALL TXD
	LD A,009H
	CALL TXD

	
		
	
	
	
	
	LD HL,CODEBUF
	LD B,C
	LD A,' '
	CALL TXD 
	LD A,':'
	CALL TXD 
	
ISTEBU:	LD A,(HL)
	CALL HEXOUT
	LD A,' '
	CALL TXD
	INC HL
	DJNZ ISTEBU
	
	
	
;------LINE ASSEMLY COMPLETED HERE 

	LD HL,(ASADR)    
	LD (ASADCODE),HL	
	LD B,0
	ADD HL,BC
	LD (ASADR),HL
	
	
	
	
YAZIM:	LD A,(CODEBUFLEN)   	;;WRITE ASSEMBLY LINE CODES FROM CODE BUFFER TO MEMORY
	LD B,A		;CODE LENGHT

	
	LD HL,(ASADCODE)  ; ASSEMBLY LINE START ADRESS
	LD DE,CODEBUF	;CODE BUFFER START ADRESS
DISYAZ:	LD A,(DE)
	LD (HL),A
	INC HL
	INC DE
	DJNZ DISYAZ    ;WRITE ASSEMBLY LINE CODES TO MEMORY
	
	
	
	
	JP AS_DON	;GO TO NEXT ASSEMBLY LINE
	;JP MA_IN
	
DIYEZ1: 	
	LD A,(DATAINP)	;CHANGE # CHAR TO OPERAND BYTE
	LD (DE),A
	INC DE
	INC C
	RET
	
DOLLAR1:
	
 	LD A,(ADRSINP)   ;CHANGE $ CHAR TO DOUBLE OPERAND BYTE
	LD (DE),A
	INC DE
	INC C
	LD A,(ADRSINP+1)
	LD (DE),A
	INC DE
	INC C
	RET
	
	
	


BYTEINP1:
	LD (DIYEZDOLAR),A
	CALL BYTEIN1 ;AFTER#
	RET
	
BYTEINP2:
	LD (DIYEZDOLAR),A
	CALL BYTEIN2 ;AFTER$
	RET



CLRBUF:	LD HL,COMINBUF
	LD B,0FH
DIS30:	LD A,00H
	LD (HL),A
	INC HL
	DJNZ DIS30  ;CLEAR INPUT BUFFER
	
	
	LD HL,CODEBUF
	LD B,0FH
DISCB:	LD A,00H
	LD (HL),A
	INC HL
	DJNZ DISCB  ;CLEAR CODE BUFFER
	
	LD A,0
	LD (LINELENGHT),A	;CLEAR ALL COUNTER BUFFERS
	LD (LINELENGHT+1),A
	LD (OPBYTECNT),A
	LD (DIYEZDOLAR),A
	LD (CODEBUFLEN),A
	LD (CODEBUFLEN+1),A
	
	
	RET
	
	

TABLE_AS:
	.DB 0AH,0DH
	.DB 'Assembler:'
	.DB 0AH,0DH
	

; THIS ROUTINE INSPIRED FROM NAIVE STRING MATCHING ALGORITHM!!

FINDCOM:		;SEARCH UTIL OF INTERPRETER 
	PUSH AF
	PUSH HL
	PUSH DE
	PUSH BC 

	LD HL,TABLECOD   ;SEARCH AND FIND MNEMONIC TABLE ADRESS INDEX
	LD (TABFINDAD),HL
LOOPF:	LD HL,(TABFINDAD)
	LD DE, COMINBUF
	LD BC,(LINELENGHT)
		
LOOPC:	LD A,(DE)   ;ORIGINAL LOOPC
	CP (HL)
	JP NZ, NOTFOUND
	INC HL
	INC DE
	DEC BC
	LD A, B
	OR C
	JP NZ,LOOPC
	
        ; === BURADA BC==0: Girişin TÜM karakterleri eşleşti ===
        ; 1) Başlangıç sınırı: match, kayıt başındaki '_' sonrası mı başladı?
        LD      DE,(TABFINDAD)   ; DE = bu denemede eşleşmenin BAŞLADIĞI adres
        DEC     DE
        LD      A,(DE)
        CP      '_'              ; kayıtlar '_' ile başlıyor
        JP      NZ, NOTFOUND     ; '_' değilse: önek/ara eşleşme → aramaya devam

        ; 2) Bitiş sınırı: sıradaki tablo baytı opcode sayısı (1..9) olmalı
        LD      A,(HL)           ; HL = eşleşen metnin hemen SONRASI
        OR      A
        JP      Z,  NOTFOUND     ; 0 olamaz → önek eşleşme
        CP      0AH
        JP      NC,NOTFOUND      ; >=0Ah ise hâlâ dize/başka veri → devam et

        JP      FOUND            ; 1..9 ise gerçek kayıt sonu → bulundu


NOTFOUND:		;IF STRING NOT FOUND INCREASE TABLE SEARCH ADRESS
	LD HL,(TABFINDAD)	;THIS IS NAIVE STRING MATCHING ALGORITHM
	INC HL
     ;THIS CODE ADDED FOR TABLE END CONTROL	

	PUSH HL			;;TABLE END CONTROL FOR SYNTAX ERROR
	PUSH DE
	
	LD HL,CODEND
	LD DE,(TABFINDAD)
	OR A     ;CLEAR CARRY FLAG
	SBC HL,DE
	JP Z,ENDCONTROL
	
	POP DE
	POP HL

	
	
     ;THIS CODE ADDED FOR TABLE END CONTROL	
	LD (TABFINDAD),HL
	JP LOOPF       ;IF NOT CONTINUE SEARCH
	

FOUND:	LD (TABFINDAD),HL     ;FINDED ADRESS IN TABLE
	POP BC
	POP DE
	POP HL
	POP AF
	RET
	
ENDCONTROL:		
	LD A,0DH
	CALL TXD
	LD A,0AH
	CALL TXD
	LD B,14
	LD HL,ERROR
DISERR:	LD A,(HL)
	CALL TXD
	INC HL
	DJNZ DISERR
	POP DE
	POP HL
	
	JP AS_DON
	
ERROR:	.DB 'Syntax '
	.DB 'error !'
	.DB 00H
	
;--INTERPRETER ENDED

;---------efex-ASSEMBLER FINISHED HERE--------------------------------------



;-----------------efex DISASSEMBLER-START-HERE----------------------------------

	
DISASSEMBLER:

    INC HL
    DEC B       ; 'R' karakterini atla
FROM_HEXDUMP:   ;IN HEXDUMP FIRST CHAR WAS D, BUT SECOND WAS NOT U; SO CONT FROM HERE..!
    LD A, (HL)
    CP 'I'
    JP NZ, ERROR_PARSER
    INC HL
    DEC B       ; 'U' karakterini atla

    LD A, (HL)
    CP 'S'
    JP NZ, ERROR_PARSER
    INC HL
    DEC B       ; 'N' karakterini atla

    ; Boşluk ve $ işaretlerini atlayan yardımcı rutini çağır
    CALL SKIP_SPACES

    ; 1-4 haneli hex adresi okuyup 16-bit'e çeviren ana rutini çağır
    CALL PARSE_HEX_ADDRESS
    JP C, ERROR_PARSER    ; Hata varsa (hiç hex karakter bulunamadıysa) çık

    ; Başarılı! 16-bitlik adres DE register'ında hazır.
    LD HL, DE             ; Çalıştırılacak adresi HL'ye al
    ;JP (HL)               ; Adrese zıpla!
    LD (ADRSINP),HL       ; SAVE DISASSEMBLER ADRESS TO 
	
	
	LD HL,TABLE_DS ;DISASSEMBLER MESSAGE
	CALL PRINT
	
	JP CONTDS
	

	
	
CONTDS:
	LD A,0
	LD (LINELENGHT),A	;CLEAR ALL COUNTER BUFFERS
	LD (LINELENGHT+1),A
	LD (OPBYTECNT),A
	LD (DIYEZDOLAR),A
	LD (CODEBUFLEN),A
	LD (CODEBUFLEN+1),A
	;LD (TOTBYTECNT),A
	LD (DISCODELEN),A
	LD (OPCNT),A
	LD (NEXTCODE),A
	LD (NEXTCODE +1),A
	
;---Disasembling adress input---
ASKDIS: 
;   LD A,'D'
;	CALL TXD
;	LD A,'-'
;	CALL TXD 
;	LD A, '$'
;	CALL TXD
;	LD A, '?'
;	CALL TXD
;	LD A, 08H
;	CALL TXD ; DISPLAY 4 CHAR INPUT PROMPT
	
;	CALL BYTEIN2
	
;	LD HL,(ADRSINP) ; 3F43 STORES RESULT ADRESS
	CALL CRLF
	
	LD HL,(ADRSINP)   ;GIRILEN ADRESS
	LD (NEXTCODE),HL	;NEXTCODE IS INCREASE LOOP ADRESS FOR DISASSEMBLER
;----------ADRESS INPUT COMPLETED HERE---

DONDISZ:
	LD A,16			;16 LINES SHOWING PER PROCESS
	LD (SECTORC),A
	
DONDISY:
	LD A,0
	LD (LINELENGHT),A	;CLEAR ALL COUNTER BUFFERS
	LD (LINELENGHT+1),A
	LD (OPBYTECNT),A
	LD (DIYEZDOLAR),A
	LD (CODEBUFLEN),A
	LD (CODEBUFLEN+1),A
	;LD (TOTBYTECNT),A
	LD (DISCODELEN),A
	LD (OPCNT),A
	

DONDISX:
	LD HL,(NEXTCODE)				;MAIN LOOP FOR DISASEMBLY LINES
	LD (DISADDR),HL        
											
	LD HL,1
	LD (LINELENGHT),HL
	LD HL,TABLECOD
	LD DE,(DISADDR)
		
DONDIS:	LD A,(DE)

	CP 0EDH
	JP Z,AFTER		;IF AFTER ED,CB,DD,FD COMMANDS 
	CP 0CBH
	JP Z,AFTER
	CP 0DDH
	JP Z,AFTER
	CP 0FDH
	JP Z,AFTER

	

	
	CP (HL)
	JP Z,CHECKINDEX     ;JP Z,FOUNDDIS
	INC HL
DVM1:	JP DONDIS


CHECKINDEX:      ;CHECK IF 0FFH AFTER CODE?
	INC HL 
	LD A,0FFH
	CP (HL)
	JP NZ,DONDIS ;NO INDEX--->CONT TO SEARC (Doğrudan DONDIS'e atla)
	DEC HL     ;INDEX FOUND, DEC HL TO COMMAND'S ADRESS
	JP FOUNDDIS
		
	;----AFTER DD DE,EE,FB,.. COMMANDS PROCESS START HERE---
AFTER: 


	LD HL,AFTERCOD   ;SEARCH AND FIND MNEMONIC TABLE ADRESS INDEX
	LD (TABFINDAD),HL
LOOPFD:	LD HL,(TABFINDAD)
	LD DE, (DISADDR)
	LD BC,2         ;(LINELENGHT)
		
LOOPCD:	LD A,(DE)
	CP (HL)
	JP NZ, NOTFOUNDD
	INC HL
	INC DE
	DEC BC
	LD A, B
	OR C
	JP NZ,LOOPCD
	
	JP FOUNDD
	
NOTFOUNDD:		;IF STRING NOT FOUND INCREASE TABLE SEARCH ADRESS
	LD HL,(TABFINDAD)	;THIS IS NAIVE STRING MATCHING ALGORITHM
	INC HL
	
     ;THIS CODE ADDED FOR TABLE END CONTROL	

	PUSH HL			;;TABLE END CONTROL FOR SYNTAX ERROR
	PUSH DE
	
	LD HL,CODEND
	LD DE,(TABFINDAD)
	OR A     ;CLEAR CARRY FLAG
	SBC HL,DE
	JP Z,ENDCONTROLD
	
	POP DE
	POP HL

	
	
     ;THIS CODE ADDED FOR TABLE END CONTROL	
	
	LD (TABFINDAD),HL
	JP LOOPFD       ;IF NOT CONTINUE SEARCH
	
ENDCONTROLD:		;UNKNOWN CODE ROUTINE; PRINT *** AND GOTO NEXT ADRESS

	LD A,0AH
	CALL TXD
	LD A,0DH
	CALL TXD

	LD HL,(DISADDR)
	LD A,H
	CALL HEXOUT
	LD A,L
	CALL HEXOUT
	LD A,' '
	CALL TXD
	LD A,' '
	CALL TXD		
	LD A,'*'
	CALL TXD
	LD A,'*'
	CALL TXD
	LD A,'*'
	CALL TXD

	

	
    	;--- DEĞİŞİKLİK BURADA BAŞLIYOR ---
    INC HL
	INC HL                  ;for aftercode commands
	LD (NEXTCODE),HL        ; Bir sonraki satırın başlangıç adresini güncelle.

	LD A,(SECTORC)          ; Satır sayacını A'ya yükle.
	DEC A                   ; Sayacı bir azalt.
	JP Z,DONE    	        ; Eğer sayaç sıfırsa (sayfa dolduysa) tuş beklemeye git.
	LD (SECTORC),A          ; Azaltılmış sayacı geri kaydet.

	JP DONDISX              ; Bir sonraki satırı sökmek için DONDISY'ye atla (DONDISX yerine).
   

	

FOUNDD:	LD HL,(TABFINDAD)
	
	LD (DISFINDAD),HL

	
	
	

;------AFTER DD DE EE FB.. COMMANDS PROCESS END HERE

	




	
FOUNDDIS:		;ANYWAY (AFTER OR SINGLE) COMMAND FOUND	
	;LD  HL,(TABFINDAD)

	LD  (DISFINDAD),HL

	LD A,0AH
	CALL TXD
	LD A,0DH
	CALL TXD
	

	LD HL,(DISFINDAD) 	;FINDED CODE FIRST BYTE
	DEC HL
	LD A,(HL)
	LD (DISCODELEN),A   	;CODE BYTE LENGHT
	DEC HL
	LD (MNENDAD),HL		;MNEMONIC END ADRESS
	
DIS45:	
    DEC HL
	LD A,(HL)
	CP '_'
	JP NZ, DIS45
	INC HL
	LD (MNESTAD),HL		;MNEMONIC START ADRESS IN TABLE
	LD A,(DISCODELEN)
	LD B,A
	LD HL,(DISADDR)
DIS51:	
    INC HL
	DEC B
	JP NZ, DIS51
	
	
					;HL HOLDS OPERAND FIRST BYTE HERE
	LD (OPERAND),HL	 ;OPERAND1: IF #; FIRST BYTE, IF $; LOW AND HIGH BYTES IN ORDER
	
		
	
DISPROC:		;WRITES DISASEMBLED CODE TO CODE BUFFER

	LD A,0DH
	CALL TXD
	LD A,0DH
	CALL TXD
	
	; BURADA MNEMONIC LENGHT IN HESAPLANMASI GEREKIYOR
;ORIGINAL CODE;;
;LD HL,(MNESTAD)
;LD D,H
;LD E,L
;LD HL,(MNENDAD)
;OR A
;SBC HL,DE
;LD (MNELEN),HL
;LD A,(MNELEN)	;AT LAST ITS 1 BYTE AND STORED IN L

;NEW CODE WITH UNDOCUMENTED 8085 INSTRUCTIONS;
	LD HL,(MNESTAD)
	LD B,H
	LD C,L
	LD HL,(MNENDAD)
	OR A
	;.DB 08H   ; UNDOCUMENTED DSUB COMMAND; HL=HL-BC CARRY AFFECTED
	SBC HL,BC
	LD (MNELEN),HL
	LD A,(MNELEN)	;AT LAST ITS 1 BYTE AND STORED IN L
	

	LD HL,(DISADDR)
	LD A,H
	CALL HEXOUT
	LD A,L
	CALL HEXOUT
	LD A,' '
	CALL TXD
	LD A,' '
	CALL TXD
		
	
	
	LD A,(MNELEN)	;AT LAST ITS 1 BYTE AND STORED IN L
	LD HL,(MNESTAD)
	LD B,A	;(MNELEN)
	INC B
DIS46:	
    LD A,(HL)
	CP '#'
	JP Z,DISDIYEZ
	CP '$'
	JP Z,DISDOLAR
	CALL TXD
DIS50:	
    INC HL
	DEC B
	JP NZ, DIS46
	

	


	LD HL,(NEXTCODE)
	LD A,(DISCODELEN) ;CODE LENGHT
	LD B,A
	LD A,(OPCNT)	;OPERAND COUND
	ADD A,B
	LD DE,0
	LD E,A
	ADD HL,DE
	LD (NEXTCODE),HL
	
	
	
	LD A,(SECTORC)
	DEC A
	JP Z,DONE    	;JP Z,MA_IN
	LD (SECTORC),A

	JP DONDISY
	;JP MA_IN		;EXIT POINT FROM DISASSEMBLER
	
DONE:	
    CALL RXD
	CP 01BH
	JP Z, INPUT         ;JP Z,MA_IN
	JP DONDISZ
	JP DONE	

		
	
DISDIYEZ:
	LD A,1
	LD (OPCNT),A
	LD A,'#'
	CALL TXD
	PUSH HL
	LD HL,(OPERAND)
	LD A,(HL)
	CALL HEXOUT
	POP HL
	JP DIS50
	
DISDOLAR:
	LD A,2
	LD (OPCNT),A
	LD A,'$'
	CALL TXD
	PUSH HL
	LD HL,(OPERAND)
	INC HL
	LD A,(HL)
	CALL HEXOUT
	DEC HL
	LD A,(HL)
	CALL HEXOUT
	POP HL
	JP DIS50
	
				

;--------------DISASSEMBLER FINISHED HERE
	


;------------------------------------MOVE---------------------------------

MOVE: 		
    ; "OVE" kelimesinin geri kalanını doğrula
    INC HL
    LD A, (HL)
    CP 'O'
    JP NZ, ERROR_PARSER
    INC HL
    LD A, (HL)
    CP 'V'
    JP NZ, ERROR_PARSER
    INC HL
    LD A, (HL)
    CP 'E'
    JP NZ, ERROR_PARSER
    INC HL

    ; --- Parametreleri Çözümle ve GÜVENLİ BİR ŞEKİLDE KAYDET ---

    ; 1. SOURCE Adresini al ve STARTADR değişkenine kaydet
    CALL SKIP_SPACES
    CALL PARSE_HEX_ADDRESS
    JP C, ERROR_PARSER
    PUSH HL              ; Buffer işaretçisini (HL) koru
    LD HL, DE            ; Okunan adresi (DE'de) HL'ye al
    LD (STARTADR), HL    ; STARTADR değişkenine kaydet (SHLD)
    POP HL               ; Buffer işaretçisini geri yükle

    ; 2. DESTINATION Adresini al ve ENDADR değişkenine kaydet
    CALL SKIP_SPACES
    CALL PARSE_HEX_ADDRESS
    JP C, ERROR_PARSER
    PUSH HL              ; Buffer işaretçisini (HL) koru
    LD HL, DE            ; Okunan adresi (DE'de) HL'ye al
    LD (ENDADR), HL      ; ENDADR değişkenine kaydet (SHLD)
    POP HL               ; Buffer işaretçisini geri yükle

    ; 3. B16 LENGHT  Adresini al ve COMMVAR değişkenine kaydet
    CALL SKIP_SPACES
    CALL PARSE_HEX_ADDRESS
    JP C, ERROR_PARSER
    PUSH HL              ; Buffer işaretçisini (HL) koru
    LD HL, DE            ; Okunan adresi (DE'de) HL'ye al
    LD (COMMVAR), HL      ; COMMVAR (LENGHT) değişkenine kaydet (SHLD)
    POP HL               ; Buffer işaretçisini geri yükle

    ; 3. Doldurulacak Değeri al (8-bit)
    ;CALL SKIP_SPACES
    ;CALL PARSE_HEX_BYTE
    ;JP C, ERROR_PARSER
    ;LD C, A              ; Doldurulacak değeri C'ye al

    ; --- MOVE İşlemini Gerçekleştir ---


;	CALL MOVE_SR     ;HL HOLDS SOURCE
;	PUSH HL
;	CALL MOVE_DT     ;DE HOLDS TARGET
;	PUSH DE
;	CALL MOVE_LNT    ;BC HOLDS LENGHT

    LD HL,(COMMVAR)
    LD B,H
    LD C,L          ;BC=LENGHT

    LD HL,(ENDADR)
    LD D,H 
    LD E,L          ;DE=DESTINATION ADRESS

    LD HL,(STARTADR) ;HL= SOURCE ADRESS



	

	
	
LOP15:	           ;HL HOLDS SOURCE,DE HOLDS TARGET,BC HOLDS LENGHT
    LD A,(HL)      ;BLOCK COPY SUBROUTINE
	LD (DE),A
	INC HL
	INC DE
	DEC BC
	LD A,B
	OR C
	JP NZ, LOP15
	
	LD HL, TABLE14   ;MOVE COMPLETE MSG
	CALL PRINT

	
	;JP MA_IN
    JP INPUT
	
	
;MOVE_SR:
;	LD HL,TBLMVSR	;  DISPLAY MOVE MSG
;	CALL PRINT

;	CALL BYTEIN2
;	LD HL,(ADRSINP) ;HL HOLDS SOURCE ADRESS
;	RET


;MOVE_DT:
;	LD HL,TBLMVDT
;	CALL PRINT

;	CALL BYTEIN2	;2 BYTE INPUT
;	LD HL, (ADRSINP)
;	EX DE,HL     ;DE HOLDS TARGET ADRESS
;	RET
	
	
;MOVE_LNT:
;	LD HL,TBLMVLN
;	CALL PRINT

;	CALL BYTEIN2	;2 BYTE INPUT
;	LD HL, (ADRSINP)  
;	LD B,H
;	LD C,L          ;BC HOLDS BLOCK LENGHT 
;	RET


	

;--------------MOVE END

;------------------------------------FILL---------------------------------

; --- FILL komutunu işleyen yeni blok ---
OLDFILL:
; --- FILL komutunu işleyen YENİ, GÜVENLİ ve NİHAİ blok ---
FILL_CMD:
    ; "ILL" kelimesinin geri kalanını doğrula
    INC HL
    LD A, (HL)
    CP 'I'
    JP NZ, ERROR_PARSER
    INC HL
    LD A, (HL)
    CP 'L'
    JP NZ, ERROR_PARSER
    INC HL
    LD A, (HL)
    CP 'L'
    JP NZ, ERROR_PARSER
    INC HL

    ; --- Parametreleri Çözümle ve GÜVENLİ BİR ŞEKİLDE KAYDET ---

    ; 1. Başlangıç Adresini al ve STARTADR değişkenine kaydet
    CALL SKIP_SPACES
    CALL PARSE_HEX_ADDRESS
    JP C, ERROR_PARSER
    PUSH HL              ; Buffer işaretçisini (HL) koru
    LD HL, DE            ; Okunan adresi (DE'de) HL'ye al
    LD (STARTADR), HL    ; STARTADR değişkenine kaydet (SHLD)
    POP HL               ; Buffer işaretçisini geri yükle

    ; 2. Bitiş Adresini al ve ENDADR değişkenine kaydet
    CALL SKIP_SPACES
    CALL PARSE_HEX_ADDRESS
    JP C, ERROR_PARSER
    PUSH HL              ; Buffer işaretçisini (HL) koru
    LD HL, DE            ; Okunan adresi (DE'de) HL'ye al
    LD (ENDADR), HL      ; ENDADR değişkenine kaydet (SHLD)
    POP HL               ; Buffer işaretçisini geri yükle

    ; 3. Doldurulacak Değeri al (8-bit)
    CALL SKIP_SPACES
    CALL PARSE_HEX_BYTE
    JP C, ERROR_PARSER
    LD C, A              ; Doldurulacak değeri C'ye al

    ; --- FILL İşlemini Gerçekleştir ---
    LD HL, (STARTADR)      ; Başlangıç adresini HL'ye yükle (LHLD)
    
    ; Bitiş adresini (ENDADR) DE'ye yükle (8085 uyumlu)
    LD A, (ENDADR)
    LD E, A 
    LD A, (ENDADR+1)
    LD D, A

; --- "Bitiş Adresi Dahil" Çalışan Doldurma Döngüsü ---
FILL_LOOP:
    LD (HL), C             ; 1. Önce değeri yaz.

    ; 2. Mevcut adres (HL), bitiş adresine (DE) ulaştı mı?
    LD A, D
    CP H
    JP NZ, FILL_CONTINUE
    LD A, E
    CP L
    JP Z, FILL_DONE        ; Eşitse, son adresi de yazdık, bitti.

FILL_CONTINUE:
    INC HL                 ; 3. Eşit değilse, adresi artır ve devam et.
    JP FILL_LOOP

FILL_DONE:
    LD HL, TABLE14F        ; "Fill complete!" mesajı
    CALL PRINT
    JP INPUT               ; Ana menüye dön

;--------------FILL END


	
;-----------------SAVE command starts here-----------------------
;HL: START ADRESS, DE:END ADRESS TO SAVE	

SAVEX: 	
SAVE_CMD:
    ; "AVE" kelimesinin geri kalanını doğrula
    INC HL
    LD A, (HL)
    CP 'A'
    JP NZ, SUBROUTINES;ERROR_PARSER ;2. HARF A DEĞİLSE SUB KOMUTUNA GIT!
    INC HL
    LD A, (HL)
    CP 'V'
    JP NZ, ERROR_PARSER
    INC HL
    LD A, (HL)
    CP 'E'
    JP NZ, ERROR_PARSER
    INC HL

    ; --- Parametreleri Çözümle ve GÜVENLİ BİR ŞEKİLDE KAYDET ---

    ; 1. Başlangıç Adresini al ve STARTADR değişkenine kaydet
    CALL SKIP_SPACES
    CALL PARSE_HEX_ADDRESS
    JP C, ERROR_PARSER
    PUSH HL              ; Buffer işaretçisini (HL) koru
    LD HL, DE            ; Okunan adresi (DE'de) HL'ye al
    LD (STARTADR), HL    ; STARTADR değişkenine kaydet (SHLD)
    POP HL               ; Buffer işaretçisini geri yükle

    ; 2. Bitiş Adresini al ve ENDADR değişkenine kaydet
    CALL SKIP_SPACES
    CALL PARSE_HEX_ADDRESS
    JP C, ERROR_PARSER
    PUSH HL              ; Buffer işaretçisini (HL) koru
    LD HL, DE            ; Okunan adresi (DE'de) HL'ye al
    LD (ENDADR), HL      ; ENDADR değişkenine kaydet (SHLD)
    POP HL               ; Buffer işaretçisini geri yükle

    ; 3. Doldurulacak Değeri al (8-bit)
    ;CALL SKIP_SPACES
    ;CALL PARSE_HEX_BYTE
    ;JP C, ERROR_PARSER
    ;LD C, A              ; Doldurulacak değeri C'ye al

    ; --- SAVE İşlemini Gerçekleştir ---
    LD HL, (STARTADR)      ; Başlangıç adresini HL'ye yükle (LHLD)
    
    ; Bitiş adresini (ENDADR) DE'ye yükle (8085 uyumlu)
    LD A, (ENDADR)
    LD E, A 
    LD A, (ENDADR+1)
    LD D, A
	
       	CALL INTSAVE ;NEEDS; HL: START ADRESS, DE:END ADRESS
       	JP INPUT
	
	

	


;SAVE_ADR1:
;	LD HL,TBLSV1
;	CALL PRINT

;	CALL BYTEIN2
;	LD HL,(ADRSINP)
;	RET

;SAVE_ADR2:
;	LD HL,TBLSV2
;	CALL PRINT
	
;	CALL BYTEIN2
;	LD DE,0
;	LD HL, (ADRSINP)
;	EX DE,HL     ;DE HOLDS END ADRESS
;	RET
	
	

	
;-------------save end----------------

;------------------INPUT--------------------------------
;INPUT DONT CHANGES ANY REGISTER!!!
;1 BYTE RESULT AT: DATAINP
;2 BYTE RESULT AT: ADRSINP-3F44H


BYTEIN2:
	PUSH AF
	PUSH HL
	PUSH BC
	PUSH DE 
 	LD HL, KEYINBUF  ;4 CHAR ADRESS INPUT
	LD B,4
DIS25:	
    CALL RXD
    CALL UPPERCASE ;NEW 
	CP 1BH
	JP Z, INPUT        ;MA_IN
	JP CHECKHEX    ;CHECK IF A VALID HEX CHAR
HEXCON2:
	LD (HL), A
	INC HL
	CALL TXD  ;PRINT NIBBLE
	DEC B
	JP NZ, DIS25  ;GET 4 NIBBLE FROM KEYINBUF TO 3F23H
	CALL INTLINR  ;  
	LD HL,(KEYINRES)
	LD (ADRSINP),HL ; TWO BYTES ADRESS AT 3F43(High), AND 3F44(Low)
	POP DE 
	POP BC
	POP HL
	POP AF
	RET
		
	
BYTEIN1:
	PUSH AF
	PUSH HL
	PUSH BC
	PUSH DE
	LD HL, KEYINBUF + 2 ;2 CHAR DATA INPUT
	LD B,2
DIS26:	
    CALL RXD
    CALL UPPERCASE ;NEW  
	CP 1BH
	JP Z, INPUT         ;MA_IN
	JP CHECKHEX2
	
HEXCON3:

	LD (HL), A
	INC HL
	CALL TXD   ;PRINT NIBBLE
	DEC B
	JP NZ, DIS26
	CALL INLIN2  
	LD A,(KEYINRES)
	LD (DATAINP),A ;1 BYTE INPUT: RESULT IN 3F42

	POP DE 
	POP BC
	POP HL
	POP AF
	RET
	
	
;---------------------------------	
;-------------------------1 BYTE CHECK IF HEX------	
CHECKHEX2:	;CHECK IF INPUT IS A REAL HEX VALUE FOR 1 BYTE INPUT
	PUSH HL
	PUSH AF
	PUSH BC
	LD HL, TABLEX   ;HEX CHAR TABLE
	LD B,16
DONHEXX2:
	CP (HL)
	JP Z,OKHEX2	;FINDED A VALID HEX CHAR, RETURN TO CONTINUE
	INC HL
	DEC B
	JP NZ, DONHEXX2
	
NOTHEX2: 
    POP BC
	POP AF
	POP HL
	JP DIS26
	
	
OKHEX2:
 	POP BC
	POP AF
	POP HL
	JP HEXCON3	;CONTINUE TO WRITE INPUT PROCESS
;--1 BYTE CHECK FINISHED
	
CHECKHEX:	;CHECK IF INPUT IS A REAL HEX VALUE FOR 2 BYTE INPUT
	PUSH HL
	PUSH AF
	PUSH BC
	LD HL, TABLEX   ;HEX CHAR TABLE
	LD B,16 ;decimal
DONHEXX:
	CP (HL)
	JP Z,OKHEX	;FINDED A VALID HEX CHAR, RETURN TO CONTINUE
	INC HL
	DEC B
	JP NZ, DONHEXX
	
NOTHEX: 
    POP BC
	POP AF
	POP HL
	JP DIS25
	
	
OKHEX: 	
    POP BC
	POP AF
	POP HL
	JP HEXCON2	;CONTINUE TO WRITE INPUT PROCESS
;--2 BYTE CHECK FINISHED
	
	
	
	
;--------------------EDIT------------------------------
	
;--------------------NEW INTERACTIVE EDIT------------------------------
EDIT:

;******************************************************************************
;* EDIT KOMUTU (Format Hatası Düzeltilmiş Nihai Versiyon)                     *
;******************************************************************************
EDIT_CMD:
    ; "DIT" kelimesinin geri kalanını doğrula
    INC HL
    LD A, (HL)
    CP 'D'
    JP NZ, ERROR_PARSER
    
    INC HL
    LD A, (HL)
    CP 'I'
    JP NZ, ERROR_PARSER
    
    INC HL
    LD A, (HL)
    CP 'T'
    JP NZ, ERROR_PARSER
    
    INC HL

    ; Adres parametresini oku
    CALL SKIP_SPACES
    CALL PARSE_HEX_ADDRESS
    JP C, NO_EDIT_ADDRESS_GIVEN
    LD HL, DE
    LD (EDITADR), HL
    JP EDIT_START_LINE

NO_EDIT_ADDRESS_GIVEN:
    LD HL, (EDITADR)        ; Adres girilmediyse, son kalınan adresi kullan

EDIT_START_LINE:
    ; --- 1. SATIRI SADECE BİR KEZ ÇİZ ---
    CALL CRLF
	LD HL, (EDITADR)
    LD (EDITADR), HL
	LD A,00H      ;inline byte counter
	LD (COMMVAR),A
    
    ; Adresi ve 16 byte'ı basan yardımcı rutini çağır
    CALL DRAW_EDIT_LINE_SIMPLE
    
    ; --- 2. İMLECİ SATIRIN BAŞINA GERİ ÇEK ---
    LD B, 48
MOVE_CURSOR_HOME:
    LD A, 08H               ; Backspace karakteri ile geri git
    CALL TXD
    DEC B
    JP NZ, MOVE_CURSOR_HOME

    LD HL, (EDITADR)        ; Aktif byte işaretçisini satır başına ayarla
	LD A,000H
	LD (COMMVAR),A          ;SATIR SAYACINI SIFIRLA

EDIT_KEY_LOOP:
    CALL RXD
    CALL UPPERCASE
    
    ; --- 3. GELEN TUŞU İŞLE ---
    CP 1BH                  ; ESC mi?
    JP Z, EDIT_EXIT
    
    CP  0DH                  ; ENTER mı?
    JP  NZ,CHK_BS
    LD  A,(COMMVAR)
    CP  0FH
    JP  Z,MOVE_DOWN_LINE     ; 16. bayttaysan bir alt satıra in
    JP  MOVE_RIGHT_KEY       ; değilse sağa git
CHK_BS:
    
    CP 08H                  ; BACKSPACE mi?
    JP Z, MOVE_LEFT_KEY
    
    CALL IS_IT_HEX          ; Hex karakter mi?
    JP C, EDIT_KEY_LOOP     ; Değilse, yoksay ve yeni tuş bekle

    ; --- GEÇERLİ HEX KARAKTERİ GİRİLDİ (değeri A'da) ---
    LD B, A                 ; İlk hanenin değerini (0-15) B'de sakla
    
GET_SECOND_HEX:
    CALL RXD
    CALL UPPERCASE
    CALL IS_IT_HEX
    JP C, GET_SECOND_HEX    ; Hex değilse, geçerli bir tuş bekle
    
    PUSH AF                 ; İkinci haneyi (A) koru
    LD A, B                 ; İlk haneyi al
    ADD A, A                ; 4 bit sola kaydır (x16)
    ADD A, A
    ADD A, A
    ADD A, A
    LD B, A                 ; B = Yüksek Nibble
    POP AF                  ; İkinci haneyi geri al
    OR B                    ; A = Yüksek Nibble | Düşük Nibble
    
    LD (HL), A              ; Yeni byte'ı hafızaya yaz!
    
;    LD A, 08H
;    CALL TXD
;    LD A, 08H
;    CALL TXD

    LD A,(HL)
    CALL HEXOUT
    LD A,' '
    CALL TXD

    LD   A,(COMMVAR)
    CP   0FH
    JP   NZ, ADVANCE_OK

    ; son sütun: caret 3 kolon ileri gitti → 3 geri al, yerinde kal
    CALL MOVE_CURSOR_LEFT
    JP   EDIT_KEY_LOOP

ADVANCE_OK:
    INC  A
    LD   (COMMVAR),A
    INC  HL
    LD   (EDITADR),HL
    JP   EDIT_KEY_LOOP

MOVE_RIGHT_KEY:
    LD   A,(COMMVAR)
    CP   0FH
    JP   Z, EDIT_KEY_LOOP        ; sınırda dur
    INC  A
    LD   (COMMVAR),A
    INC  HL
    LD   (EDITADR),HL
    CALL MOVE_CURSOR_RIGHT       ; ESC [ 3 C
    JP   EDIT_KEY_LOOP
    
;MOVE_LEFT_KEY:

;   JP EDIT_KEY_LOOP

MOVE_LEFT_KEY:
    LD   A,(COMMVAR)
    CP   00H
    JP   Z, EDIT_KEY_LOOP        ; baştayken fren: hiçbir şey yapma
    CALL MOVE_LEFT               ; tek yerde azalt: burada yapar
    JP   EDIT_KEY_LOOP


MOVE_SAG_KEY:
    LD  A,(COMMVAR)
    CP  0FH
    JP  Z,EDIT_KEY_LOOP
    INC A
    LD  (COMMVAR),A
    INC HL
    LD  (EDITADR),HL
    CALL MOVE_CURSOR_RIGHT
    JP  EDIT_KEY_LOOP
    
MOVE_CURSOR_RIGHT_ANSI:

    JP EDIT_KEY_LOOP


MOVE_LEFT:
	LD A,(COMMVAR)
	DEC A 
	LD (COMMVAR),A
    DEC HL
    LD (EDITADR), HL
    LD A, 1BH
    CALL TXD
    LD A, '['
    CALL TXD
    LD A, '3'
    CALL TXD
    LD A, 'D'
    CALL TXD
    ;JP EDIT_KEY_LOOP
	RET
    
MOVE_CURSOR_RIGHT: ;3 char
    LD A, 1BH
    CALL TXD
    LD A, '['
    CALL TXD
    LD A, '3'
    CALL TXD
    LD A, 'C'
    CALL TXD
    ;JP EDIT_KEY_LOOP
	RET

MOVE_CURSOR_LEFT: ;3 char
    LD A, 1BH
    CALL TXD
    LD A, '['
    CALL TXD
    LD A, '3'
    CALL TXD
    LD A, 'D'
    CALL TXD
    ;JP EDIT_KEY_LOOP
	RET






MOVE_DOWN_LINE:
    LD HL, (EDITADR)
   ; LD DE, 16            ;16 yanlış satır sonundayız zaten 16 eklenmiş
    ;ADD HL, DE
	INC HL 				; 1 EKLEMEK YETERLİ :)
    LD (EDITADR), HL
	LD  A,00H
    LD  (COMMVAR),A     ; imleç sütun sayacını sıfırla (0..15)
    JP EDIT_START_LINE

EDIT_EXIT:
    CALL CRLF
    JP INPUT
; IS_IT_HEX alt programının kodunda olduğundan emin ol!

;******************************************************************************
;* IS_IT_HEX ALT PROGRAMI (Daha önce konuşmuştuk, şimdi ekliyoruz)            *
;* Girdi: A = Kontrol edilecek karakterin ASCII kodu                          *
;* Çıktı: Başarılıysa -> Carry=0, A=Sayısal değer (0-15)                      *
;* Başarısızsa -> Carry=1                                              *
;******************************************************************************
IS_IT_HEX:
    PUSH BC
    LD B, A
    CALL UPPERCASE
    SUB '0'
    JP C, NOT_A_HEX_KEY
    CP 10
    JP C, IS_A_HEX_KEY
    LD A, B
    CALL UPPERCASE
    SUB 'A'
    JP C, NOT_A_HEX_KEY
    CP 6
    JP NC, NOT_A_HEX_KEY
    ADD A, 10
IS_A_HEX_KEY:
    POP BC
    OR A
    RET
NOT_A_HEX_KEY:
    POP BC
    SCF
    RET	

;******************************************************************************
;* DRAW_EDIT_LINE_SIMPLE ALT PROGRAMI                                         *
;* Açıklama: SADECE EDIT komutu için, HL'nin gösterdiği adresten başlayarak,   *
;* adresi ve 16 byte'lık hex veriyi tek bir satırda basar.                      *
;* Girdi: HL = Basılacak satırın başlangıç adresi                             *
;* Çıktı: HL = HL + 16 (Bir sonraki satırın başlangıcı)                       *
;* Korur: AF, BC, DE                                                          *
;******************************************************************************
DRAW_EDIT_LINE_SIMPLE:
    PUSH AF             ; Kullanılacak register'ları koru
    PUSH BC
    PUSH DE
    
    ; Adresi basarken HL'yi geçici olarak koru
    PUSH HL
    LD A, H
    CALL HEXOUT
    LD A, L
    CALL HEXOUT
    LD A, ':'
    CALL TXD
    LD A, ' '
    CALL TXD
    POP HL              ; Basılacak asıl adresi geri al

    ; 16 byte'lık veriyi hex olarak bas
    LD B, 16
DRAW_EDIT_LOOP:
    LD A, (HL)
    CALL HEXOUT
    LD A, ' '
    CALL TXD
    INC HL
    DEC B
    JP NZ, DRAW_EDIT_LOOP
    
    POP DE              ; Korunan register'ları geri yükle
    POP BC
    POP AF
    RET    
;------------------------EDIT ENDED HERE--------------------		  


;------------------GO TO ADRESS-(RUN)----------------------

	
	
;RUN_ADR:
;	LD HL,TBLRUNN	;  DISPLAY RUN ADRESS MSG
;	CALL PRINT
	
;	LD A,'G'
;	CALL TXD
;	LD A,'-'
;	CALL TXD 
;	LD A, '$'
;	CALL TXD
;	LD A, '?'
;	CALL TXD
;	LD A, 08H
;	CALL TXD ; DISPLAY 4 CHAR INPUT PROMPT
;	CALL BYTEIN2
;	
;	LD HL,TABLERUN	;  DISPLAY RUNNING MSG
;	CALL PRINT
	
;	LD HL, (ADRSINP)
;	JP (HL)
;------------------GO TO ADRESS-(RUN)----------------------
RUN_ADR:
    INC HL
    DEC B       ; 'R' karakterini atla

    LD A, (HL)
    CP 'U'
    JP NZ, ERROR_PARSER
    INC HL
    DEC B       ; 'U' karakterini atla

    LD A, (HL)
    CP 'N'
    JP NZ, ERROR_PARSER
    INC HL
    DEC B       ; 'N' karakterini atla

    ; Boşluk ve $ işaretlerini atlayan yardımcı rutini çağır
    CALL SKIP_SPACES

    ; 1-4 haneli hex adresi okuyup 16-bit'e çeviren ana rutini çağır
    CALL PARSE_HEX_ADDRESS
    JP C, ERROR_PARSER    ; Hata varsa (hiç hex karakter bulunamadıysa) çık

    ; Başarılı! 16-bitlik adres DE register'ında hazır.
    LD HL, DE             ; Çalıştırılacak adresi HL'ye al
    JP (HL)               ; Adrese zıpla!

;-----------------------RUN CMD ENDED------------------------------   

;WARMSTART 
WARMSTART:
    INC HL
    DEC B       ; 'W' karakterini atla

    LD A, (HL)
    CP 'A'
    JP NZ, ERROR_PARSER
    INC HL
    DEC B       ; 'A' karakterini atla

    LD A, (HL)
    CP 'R'
    JP NZ, ERROR_PARSER
    INC HL
    DEC B       ; 'R' karakterini atla

    LD A, (HL)
    CP 'M'
    JP NZ, ERROR_PARSER
    INC HL
    DEC B       ; 'M' karakterini atla

    JP GREET




;-------------------USEFUL SUBROUTINES-----------
SUBROUTINES:
   ; INC HL
   ; DEC B       ; 'S' karakteri zaten SAve de atlandı!

    LD A, (HL)
    CP 'U'
    JP NZ, ERROR_PARSER
    INC HL
    DEC B       ; 'U' karakterini atla

    LD A, (HL)
    CP 'B'
    JP NZ, ERROR_PARSER
    INC HL
    DEC B       ; 'B' karakterini atla


    
 	LD A,0AH
	CALL TXD
	LD A,0DH
	CALL TXD
	
		
	LD HL,TABLE22
	CALL PRINT
	
	
;HELP1:
	LD HL,TXD
	LD A,H
	CALL HEXOUT
	LD A,L
	CALL HEXOUT
	
	LD A,0AH
	CALL TXD
	LD A,0DH
	CALL TXD
		


	LD HL,TABLEH1
	CALL PRINT
			

	
	LD HL,RXD
	LD A,H
	CALL HEXOUT
	LD A,L
	CALL HEXOUT
	
	LD A,0AH
	CALL TXD
	LD A,0DH
	CALL TXD
		
	LD HL,TABLEH2
	CALL PRINT



	
	
	LD HL,BYTEIN2
	LD A,H
	CALL HEXOUT
	LD A,L
	CALL HEXOUT
	
	LD HL,TABLEH3
	CALL PRINT
	
	LD HL,TABLEH4
	CALL PRINT
	
	LD HL,BYTEIN1
	LD A,H
	CALL HEXOUT
	LD A,L
	CALL HEXOUT

	LD HL,TABLEH5
	CALL PRINT
	
	LD HL,TABLEH6
	CALL PRINT
	
	LD HL,HEXOUT
	LD A,H
	CALL HEXOUT
	LD A,L
	CALL HEXOUT
	
	LD HL,TABLEH7
	CALL PRINT	
	
	LD HL,TABLEH8
	CALL PRINT
	
	LD HL,INPUT     ;MA_IN
	LD A,H
	CALL HEXOUT
	LD A,L
	CALL HEXOUT
	
	LD A,0AH
	CALL TXD
	LD A,0DH
	CALL TXD
	
	
	
	LD HL,TABLEH10
	CALL PRINT
	
	LD HL,DELAY_1S    ;1S DELAY REGISTER SAVING
	LD A,H
	CALL HEXOUT
	LD A,L
	CALL HEXOUT

	LD A,0AH
	CALL TXD
	LD A,0DH
	CALL TXD

	LD HL,TABLEH11
	CALL PRINT
	
	LD HL,PRINT
	LD A,H
	CALL HEXOUT
	LD A,L
	CALL HEXOUT

	LD A,0AH
	CALL TXD
	LD A,0DH
	CALL TXD
	
	
	JP INPUT
	   


;---SKIP SPACES IN BUFFER ---
SKIP_SPACES:
SKIP_LOOP:
    LD A, (HL)
    CP ' '
    JP NZ, CHECK_DOLLAR
    INC HL
    DEC B
    JP SKIP_LOOP

CHECK_DOLLAR:
    CP '$'
    JP NZ, DONE_SKIPPING
    INC HL
    DEC B
    JP SKIP_LOOP

DONE_SKIPPING:
    RET
;----------------------skip spaces ended here-------------------------
			
	

;----------------INPUT HEX TO BYTE CONVERTER 2 BYTE OR 1 BYTE---------
INTLINR:                   ;4 NIBBLE  INPUT   
	LD HL, KEYINBUF -1 ; 
	LD A,(HL)
	CALL BYTERDR 
	LD (KEYINRES + 1),A 
	
INLIN2:	
    LD HL, KEYINBUF + 1       ;2 NIBBLE INPUT
	LD A,(HL)
	CALL BYTERDR 
	LD (KEYINRES),A 
	RET
	

BYTERDR:
		
	LD	D,000h		;Set up   ;	* Get 2 ASCII chrs as hex byte	*
	CALL	HEXCONR		;Get byte and convert to hex
	ADD	A,A		;First nibble so
	ADD	A,A		;multiply by 16
	ADD	A,A		;
	ADD	A,A		;
	LD	D,A		;Save hi nibble in D
HEXCONR:
	
	INC HL                ;HL:FF21
	
	LD A, (HL)
		
	;CALL	RXD		;Get next chr
	SUB	030h		;Makes '0'-'9' equal 0-9
	CP	00Ah		;Is it 0-9 ?
	JP	C,NALPHAR	;If so miss next bit
	SUB	007h		;Else convert alpha
NALPHAR:	
	OR	D		;Add hi nibble back
	RET			;RESULT STORED IN A REGISTER!
;------------------BYTE CONVERTER FINISHED HERE---------------


;---------------LOAD HEX FILE ROUTINE
LOADERZ:
    INC HL
    DEC B ; H RECEIVED, SO DECREASE POINTER AND COUNTER
    LD A,(HL)
    CP 'O'
    JP NZ, ERROR_PARSER
    INC HL
    DEC B ; E RECEIVED, SO DECREASE POINTER AND COUNTER
    LD A,(HL)
    CP 'A'
    JP NZ, ERROR_PARSER
    INC HL
    DEC B ; L RECEIVED, SO DECREASE POINTER AND COUNTER
    LD A,(HL)
    CP 'D'
    JP NZ, ERROR_PARSER
    JP LOADEXEC

LOADEXEC:
	
	
	LD HL,TABLE25         ;LOADING.. MSG
	CALL PRINT	
	
	CALL INTLIN1
	
	
LOAD_ED:            ;load comlett, turn to main loop (INPUT)
	
	LD HL,TABLE2; FILE LOADED MESAGE
    CALL PRINT
	
	LD A,'$'
	CALL TXD
	
	LD HL,(LOADSTADR)  ;DOWNLOADED FILE START ADRESS
	LD A,H
	CALL HEXOUT
	LD A,L
	CALL HEXOUT

	LD A,0AH
	CALL TXD
	LD A,0DH
	CALL TXD
	LD A,07H
	CALL TXD

    CALL GETGARBAGE    ;CLEAR GARBAGE
	
	JP INPUT
	


; -------- RX kuyruğunu boşalt --------
GETGARBAGE:   ;RX ROUTINE WITHOUT POLL WAIT

fl_loop:
    in   a,(SER_STAT)
    and  RXRDY_MASK
    jr   z,fl_done          ; hazır değil -> çık
    in   a,(SER_DATA)        ; baytı çöpe at
    jr   fl_loop
fl_done:
    ret	

 
	
	
		
;	*********************************
;	*				*
;	*     Get Intel hex record	*
;	*				*
;	*********************************

;Short version - no checksum calculation.

;------------------- LOAD HEX (Checksum'lu) -------------------

INTLIN1:
        LD      A,00H
        LD      (HEXLDREG),A
INTLIN:
        ; ':' gelene kadar bekle
WAIT_COLON:
        CALL    RXD
        CP      1BH
        RET     Z
        CP      ':'
        JP      NZ, WAIT_COLON

        ; ----- Yeni kayıt: checksum akümülatörü sıfırla -----
        XOR     A
        LD      E,A

        ; LENGTH
        CALL    BYTERD
        LD      B,A
        ADD     A,E
        LD      E,A

        ; ADDRESS HI
        CALL    BYTERD
        LD      H,A
        ADD     A,E
        LD      E,A

        ; ADDRESS LO
        CALL    BYTERD
        LD      L,A
        ADD     A,E
        LD      E,A

        ; Başlangıç adresini bir kez kaydet
        LD      A,(HEXLDREG)
        CP      01H
        JP      Z, GOT_RECT
        LD      A,01H
        LD      (HEXLDREG),A
        LD      (LOADSTADR),HL

GOT_RECT:
        ; RECORD TYPE
        CALL    BYTERD
        LD      D,A                  ; D = rectype
        ADD     A,E
        LD      E,A

        LD      A,D
        CP      01H
        JP      Z, CHK_EOF           ; EOF → veri yok, checksum oku/doğrula
        CP      00H
        JP      NZ, SKIP_DATA        ; 00 dışı tip → yazma, sadece toplamla atla

; ---- DATA (type 00): B bayt yaz + toplam ----
DATAIN:
        LD      A,B
        OR      A
        JP      Z, READ_CHK
        CALL    BYTERD
        LD      (HL),A
        INC     HL
        ADD     A,E
        LD      E,A
        DEC     B
        JP      NZ, DATAIN
        JP      READ_CHK

; ---- 00 dışı tipler: B baytı sadece toplamla ----
SKIP_DATA:
        LD      A,B
        OR      A
        JP      Z, READ_CHK
SKIP_LOOPLL:
        CALL    BYTERD
        ADD     A,E
        LD      E,A
        DEC     B
        JP      NZ, SKIP_LOOPLL

; ---- CHECKSUM baytı: (E + chk) & 0xFF == 0 olmalı ----
READ_CHK:
        CALL    BYTERD              ; A = checksum
        ADD     A,E
        JP      NZ, LOAD_ERROR
        JP      INTLIN              ; sonraki kayda

; ---- EOF checksum’u da doğrula, sonra LOAD_ED ----
CHK_EOF:
        CALL    BYTERD
        ADD     A,E
        JP      NZ, LOAD_ERROR
        JP      LOAD_ED

; ---- Hata mesajı (istersen INPUT'a dön) ----
LOAD_ERROR:
        LD      A,0DH
        CALL    TXD
        LD      A,0AH
        CALL    TXD
        LD      HL, TAB_LOAD_ERR
        CALL    PRINT
        CALL   GETGARBAGE   ;FLUSH_RX_ALL
        JP      INPUT               ; ya da RET, akışına göre

TAB_LOAD_ERR:
        .DB 0AH,0DH
        .DB 'Checksum Err!'
        .DB 00H
	
	
   

BYTERD:	
    LD	D,000h		;Set up   ;	* Get 2 ASCII chrs as hex byte	*
	CALL	HEXCON		;Get byte and convert to hex
	ADD	A,A		;First nibble so
	ADD	A,A		;multiply by 16
	ADD	A,A		;
	ADD	A,A		;
	LD	D,A		;Save hi nibble in D
HEXCON:	
    CALL	RXD		;Get next chr
	SUB	030h		;Makes '0'-'9' equal 0-9
	CP	00Ah		;Is it 0-9 ?
	JP	C,NALPHA	;If so miss next bit
	SUB	007h		;Else convert alpha
NALPHA:	
    OR	D		;Add hi nibble back
	RET			;


;-------------------------Hex load finished-----------------

;--------------------------INTEL HEX SAVE ROUTINE
;,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,
;INTEL HEX SAVE PROGRAM         ;
;,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,
;	LD HL,START ADRESS
;	LD DE, END ADRESS
	
;--------------------------INTEL HEX SAVE ROUTINE (checksum'lu, sağlam)------
;  Giriş: HL = başlangıç adresi
;         DE = bitiş adresi (exclusive)
;  Yan etkiler: HL ilerler; DE, kalan toplam uzunluğu tutar
;-----------------------------------------------------------------------------

INTSAVE:
    ; DE = toplam uzunluk = (bitiş - başlangıç)
    PUSH HL
    EX   DE,HL            ; HL = bitiş, DE = başlangıç
    OR   A                ; carry temizle
    SBC  HL,DE            ; HL = bitiş - başlangıç
    EX   DE,HL            ; DE = toplam byte sayısı
    POP  HL               ; HL = başlangıç

    ; Başta bir CR/LF (opsiyonel)
    LD   A,0DH
    CALL TXD
    LD   A,0AH
    CALL TXD

;---- Kayıt üretim döngüsü ---------------------------------------------------
SAVE_NEXT_REC:
    LD   A,D
    OR   A
    JR   NZ, SAVE_LEN_16          ; 256'dan büyükse → 16
    LD   A,E
    CP   10H
    JR   C,  SAVE_LEN_E           ; <16 ise → E
SAVE_LEN_16:
    LD   B,10H
    JR   SAVE_MAKE_REC
SAVE_LEN_E:
    LD   B,A                      ; B = bu satırın LL değeri

;---- Bir data kaydı yaz -----------------------------------------------------
SAVE_MAKE_REC:
    ; satır checksum toplamını sıfırla
    XOR  A
    LD   (SAVECHCK),A

    ; ':' yaz
    LD   A,':'
    CALL TXD

    ; LL yaz + toplama ekle
    LD   A,B
    CALL HEXOUT
    LD   C,B
    LD   A,(SAVECHCK)
    ADD  A,C
    LD   (SAVECHCK),A

    ; Adres HI yaz + toplama ekle
    LD   A,H
    LD   C,A
    LD   A,(SAVECHCK)
    ADD  A,C
    LD   (SAVECHCK),A
    LD   A,C
    CALL HEXOUT

    ; Adres LO yaz + toplama ekle
    LD   A,L
    LD   C,A
    LD   A,(SAVECHCK)
    ADD  A,C
    LD   (SAVECHCK),A
    LD   A,C
    CALL HEXOUT

    ; Type = 00h (yaz + toplama; 0 eklemek fark etmez ama tutarlılık için)
    LD   A,00H
    CALL HEXOUT
    ; toplam = toplam + 0 (değişmez)

    ; Bu satırın B byte verisini yaz
    CALL YAZ

    ; Kalan veri var mı?
    LD   A,D
    OR   E
    JR   NZ, SAVE_NEXT_REC

;---- EOF kaydı --------------------------------------------------------------
SAVE_EOF:
    ; ':00000001FF' + CR/LF
    LD   A,':'
    CALL TXD
    LD   A,00H              ; LL
    CALL HEXOUT
    LD   A,00H              ; Addr hi
    CALL HEXOUT
    LD   A,00H              ; Addr lo
    CALL HEXOUT
    LD   A,01H              ; Type = 01 (EOF)
    CALL HEXOUT
    LD   A,0FFH             ; Checksum = FF  (-(0+0+0+1))
    CALL HEXOUT
    LD   A,0DH
    CALL TXD
    LD   A,0AH
    CALL TXD
    RET

;---- B bayt veri yaz + checksum’a ekle + satır checksum üret ----------------
;  Giriş: B = bu satırın uzunluğu (LL), HL = kaynak adres
;         DE = kalan toplam uzunluk
;  Çıkış: HL += B, DE -= B, B = 0
YAZ:
YAZ_LOOP:
    LD   A,B
    OR   A
    JR   Z,  YAZ_END

    LD   A,(HL)             ; A = data
    LD   C,A                ; C = data (geçici)

    ; checksum += data
    LD   A,(SAVECHCK)
    ADD  A,C
    LD   (SAVECHCK),A

    ; veriyi yaz
    LD   A,C
    CALL HEXOUT

    INC  HL
    DEC  DE
    DEC  B
    JR   YAZ_LOOP

YAZ_END:
    ; checksum = iki’nin tümleyeni
    LD   A,(SAVECHCK)
    CPL
    INC  A
    CALL HEXOUT

    ; satır sonu
    LD   A,0DH
    CALL TXD
    LD   A,0AH
    CALL TXD
    RET
		
;------------------------------SAVE FINISHED




;----------------------HEXOUT--------------------------------------------
		
	
	
;HEXOUT DO NOT CHANGES ANY REGISTER	
HEXOUT:	
    PUSH BC ; THIS SUBROUTINE SENDS CONTENTS OF ACC TO TERMINAL AS 
	PUSH DE ; TWO CHAR HEX VALUE (ASCII) 
	PUSH HL
	PUSH AF
	
	AND 0F0H
	RRA
	RRA
	RRA
	RRA
	LD (HIGHNIBBLE),A  ;HIGH NIBBLE SYSTEM VARIABLE
	CALL HEXAS
	
	POP AF
	PUSH AF
	AND 00FH
	LD (LOWNIBBLE),A  ;LOW NIBBLE SYSTEM VARIABLE
	CALL HEXAS
	
	POP AF
	POP HL
	POP DE
	POP BC
	
	RET
	
HEXAS:	
    LD HL, TABLEX ; HEX NIBBLE TO ASCII CONVERTER
	LD  B, 0	;ADDING HL WITH A
	LD  C, A
	ADD HL, BC
       	LD A,(HL)
	CALL TXD ;TXD ROUTINE
	RET
		
TABS_START:
	.DB 0,0,0,0,0,0,0,0
	.DB 0,0,0,0,0,0,0,0
	.DB 0,0,0,0,0,0,0,0
		

;HEXOUT DO NOT CHANGES ANY REGISTER
;-----------------------HEXOUT ENDED HERE------------------------

;TXD ROUTINE sends contents of A REGISTER  to serial out pin 
;19200 BAUD, 8-N-1


TXD:    PUSH AF
LOPTX: 	IN A,(01H)
	AND 001H     ;TXRDY?
	JP Z, LOPTX
        POP AF
	OUT (00H),A
        RET
	
;----------------------------------------------------------------------------------
;RXD ROUTINE receives 1 bayt from serial  to A REGISTER 
;19200 BAUD, 8-N-1

RXD:    
	LD A,037H
	OUT (01),A ;ENABLE TX AND RX AND CLEAR ERR BITS
	
LOPTR: 	IN A,(01H)
	AND 002H     ;TXRDY?
	JP Z, LOPTR
        IN A,(00H)   ;RECEIVE CHAR
	RET
	
;----------------------------COMM ROUTINES ENDED HERE-------------------------        

TABLEX:	
    .DB '0','1','2','3','4','5','6','7'
	.DB '8','9','A','B','C','D','E','F'
TABLE28:
	.DB 0AH,0DH
	.DB 'ENTER AD:'
	.DB 00H
TABLE29:
	.DB 0AH,0DH
	.DB 'ENTER DT:'
	.DB 00H
	
TABLE: 	
    .DB 0CH,0DH
	.DB 'Efex-z80 '
	.DB 'By M.Peker '
    .DB 'BUF-ROM-V10'

	.DB 0AH,0DH
	.DB 'Creative Commons '
	.DB 'BY-NC-ND 4.0'
	.DB 0AH,0DH
    .DB '2025'
    .DB 0AH,0DH
    .DB 0AH,0DH 
	.DB 'Ready.'
	.DB 0AH,0DH
	.DB 07H
	.DB 00H
	
	
TABLE13:
	.DB 0AH,0DH,07H
	.DB 'Press '
	.DB 'any key '
	.DB 'to send !'
	.DB 0AH,0DH
	.DB 00H
	
	

	
TABLE2: 
    .DB 0DH 
	.DB 'loaded '
	.DB 'adress:'
	.DB 00H

TABLE25: 
	.DB 0DH
	.DB 'Hex Loading'
	.DB '...'
	.DB 00H
        
		
	
	
TABLE6:	
    .DB 0AH,0DH
	.DB 'C:\>'
	.DB 00H
	
TABLE21:
	.DB 0AH,0DH

    .DB 0AH,0DH
    .DB '_________Coding______________'
    .DB 0AH,0DH

    

	
	
	.DB ' ASM   Assembler'
	;.DB 'Assembler'
	.DB 0AH,0DH
	
	
	.DB ' DIS   Disassembler'
	;.DB 'Disassembler'
	.DB 0AH,0DH
    .DB 0AH,0DH
    .DB '________Load & Save__________'
    .DB 0AH,0DH
	
	
	
	.DB ' LOAD  intel hex files'

	.DB 0AH,0DH
	

	.DB ' SAVE  intel hex files'

	.DB 0AH,0DH
    .DB 0AH,0DH
    .DB '_____Memory operations_______'

	.DB 0AH,0DH
	

	.DB ' EDIT  memory adress  '

	.DB 0AH,0DH

    .DB ' DUMP  memory content '
	.DB 0AH,0DH

    .DB ' MOVE  memory blocks  '
	.DB 0AH,0DH

    .DB ' FILL  memory by value'
	.DB 0AH,0DH
    .DB 0AH,0DH
    .DB '______Run Forest run!________'
  	
	.DB 0AH,0DH

    .DB ' RUN   program adress '
 	.DB 0AH,0DH

    .DB ' SUB   useful subroutines'
    .DB 0AH,0DH
	
	
	.DB ' WARM  warmstart monitor'

	.DB 0AH,0DH
	
	

	
	

	
	
		

	

	
	


	.DB 00H
	
	
TABLEH10:	
	.DB 'DELAY  (S):  $'
	.DB 000H

TABLEH11:	
	.DB 'PRINT  (S):  $'
	.DB 000H	
	

	
TABLEH8:	
	.DB 'PROMPT (R):  $'
	.DB 000H
		
TABLEH7:
	
	.DB ' A -> UART'
	.DB 0AH,0DH
	.DB 000H
	
TABLEH6:
	
	.DB 'HEXOUT (S):  $'
	.DB 000H
	
	
	
TABLEH5:
	
	.DB ' -> FF42'
	.DB 0AH,0DH
	.DB 000H
	
	
TABLEH4:	
	.DB 'BYTEIN (S):  $'
	.DB 000H

TABLEH3:	
	
	
	.DB ' -> FF43-FF44'
	.DB 0AH,0DH
	.DB 000H

TABLEH2:            ;
	.DB 'WORDIN (S):  $'
	.DB 000H	
	
TABLEH1:
	.DB 'RXD    (S):  $'
	.DB 000H	
	
TABLE22:

	
	.DB 'TXD    (S):  $'
	.DB 000H
	
TABLE_ASS:
	.DB 0AH,0DH
	.DB 'Assembler :'
	.DB 0AH,0DH
	.DB 000H
	
TBLRUNN:
	.DB 0AH,0DH
	.DB 'Program Run '
	.DB 'Adress ?'
	.DB 0AH,0DH
	.DB 000H
	
TBLDUMP:
	.DB 0AH,0DH
	.DB 'Hexdump memory..'
	.DB 0AH,0DH
	.DB 000H
	
TBLMVSR:
	.DB 0AH,0DH
	.DB 'Move Source '
	.DB '$?',08H
	.DB 000H

	
TBLMVDT:
	.DB 020H,020H
	.DB 'Destination  '
	.DB '$?',08H
	.DB 000H
	
TBLMVLN:
	.DB 020H,020H
	.DB 'Lenght '
	.DB '$?',08H
	.DB 000H

TABLE14:
	.DB 0AH,0DH 
	.DB 'Move '
	.DB 'complete !'
	.DB 0AH,0DH
	.DB 000H	
	
TBLFILL:
	.DB 0AH,0DH
	.DB 'Fill memory '
	.DB 0AH,0DH
	.DB 000H	

TBLFLSR:
	;.DB 0AH,0DH      ;
	.DB 'Start adr. :'
	.DB '$?',08H
	.DB 000H

	
TBLFLDT:
	.DB 020H,020H     ;
	.DB 'Lenght       '
	.DB '$?',08H
	.DB 00H 	
	
TBLFLBY:
	.DB 020H,020H     ;
	.DB 'Fill with    '
	.DB '#?',08H
	.DB 00H
	


TABLE14F:
	.DB 0AH,0DH 
	.DB 'Fill '
	.DB 'complete !'
	.DB 0AH,0DH
	.DB 000H
	
	
TBLSAVE:
	.DB 0AH,0DH
	.DB 'Save memory '
	.DB 0AH,0DH
	.DB 000H	
	
TBLSV1:	.DB 0AH,0DH
	.DB 'Start '
	.DB '$?',08H
	.DB 000H
	
TBLSV2:	.DB 0AH,0DH
	.DB 'End   '
	.DB '$?',08H
	.DB 000H
	
		
TABLEDIT:
	.DB 'Edit memory :'
	.DB '$'
	.DB 000H	
	
;TABLE_AS:
;	.DB 0AH,0DH
;	.DB 'Assembler:'
;	.DB 0AH,0DH
;	.DB 000H
	
;ERROR:	
;    .DB 'Syntax '
;	.DB 'error !'
;	.DB 000H	
	
TABLE_DS:
	.DB 0AH,0DH
	.DB 'Disassembly '
	.DB 'listing:'
	.DB 0AH,0DH
	.DB 000H
	
TABLERUN:
	.DB 0AH,0DH
	.DB 'Running..'
	.DB 000H	

TABLEERR:

    .DB 0AH,0DH
    .DB 'Error !'
    .DB 000H


	
	
;--ASSEMBLER AND DISASSEMBLER OPERATES ON SAME TABLE
;
;        
;INSTRUCTION , VIRGUL, CODE COUNT,MACHINE CODE,OPERAND #-$-NULL, TOTAL BYTE COUNT 
;2CH VIRGUL DEMEK
;BU ASSEMBLER .DB DE VIRGUL KABUL ETMIYOR!!!

	
TABLECOD:

		
	.DB '_ADC A',2CH,'(HL)',1,08EH,0FFH

	.DB '_ADC A',2CH,'A',1,08FH,0FFH	;0FFH IS NULL INDEX CODE TO FIND  COMMAND 
	.DB '_ADC A',2CH,'B',1,088H,0FFH	;'_' IS INDEX CHAR TO FIND MNEMONIC
	.DB '_ADC A',2CH,'C',1,089H,0FFH
	.DB '_ADC A',2CH,'D',1,08AH,0FFH
	.DB '_ADC A',2CH,'E',1,08BH,0FFH
	.DB '_ADC A',2CH,'H',1,08CH,0FFH
	.DB '_ADC A',2CH,'L',1,08DH,0FFH
	.DB '_ADC A',2CH,'#',1,0CEH,0FFH

   
	.DB '_ADD A',2CH,'(HL)',1,086H,0FFH

	.DB '_ADD A',2CH,'A',1,087H,0FFH
	.DB '_ADD A',2CH,'B',1,080H,0FFH
	.DB '_ADD A',2CH,'C',1,081H,0FFH
	.DB '_ADD A',2CH,'D',1,082H,0FFH
	.DB '_ADD A',2CH,'E',1,083H,0FFH
	.DB '_ADD A',2CH,'H',1,084H,0FFH
	.DB '_ADD A',2CH,'L',1,085H,0FFH
	.DB '_ADD A',2CH,'#',1,0C6H,0FFH
	.DB '_ADD HL',2CH,'BC',1,009H,0FFH
	.DB '_ADD HL',2CH,'DE',1,019H,0FFH
	.DB '_ADD HL',2CH,'HL',1,029H,0FFH
	.DB '_ADD HL',2CH,'SP',1,039H,0FFH

   
	.DB '_AND (HL)',1,0A6H,0FFH

	.DB '_AND A',1,0A7H,0FFH
	.DB '_AND B',1,0A0H,0FFH
	.DB '_AND C',1,0A1H,0FFH
	.DB '_AND D',1,0A2H,0FFH
	.DB '_AND E',1,0A3H,0FFH
	.DB '_AND H',1,0A4H,0FFH
	.DB '_AND L',1,0A5H,0FFH
	.DB '_AND #',1,0E6H,0FFH
	

	   

	   
	.DB '_CALL C',2CH,'$',1,0DCH,0FFH
	.DB '_CALL M',2CH,'$',1,0FCH,0FFH
	.DB '_CALL NC',2CH,'$',1,0D4H,0FFH
	.DB '_CALL NZ',2CH,'$',1,0C4H,0FFH
	.DB '_CALL P',2CH,'$',1,0F4H,0FFH
	.DB '_CALL PE',2CH,'$',1,0ECH,0FFH
	.DB '_CALL PO',2CH,'$',1,0E4H,0FFH
	.DB '_CALL Z',2CH,'$',1,0CCH,0FFH
	.DB '_CALL $',1,0CDH,0FFH
	   
	.DB '_CCF',1,03FH,0FFH
	   
	.DB '_CP (HL)',1,0BEH,0FFH

	.DB '_CP A',1,0BFH,0FFH
	.DB '_CP B',1,0B8H,0FFH
	.DB '_CP C',1,0B9H,0FFH
	.DB '_CP D',1,0BAH,0FFH
	.DB '_CP E',1,0BBH,0FFH
	.DB '_CP H',1,0BCH,0FFH
	.DB '_CP L',1,0BDH,0FFH
	.DB '_CP #',1,0FEH,0FFH
	


	.DB '_CPL',1,02FH,0FFH
	   
	.DB '_DAA',1,027H,0FFH
	   
	.DB '_DEC (HL)',1,035H,0FFH

	.DB '_DEC A',1,03DH,0FFH
	.DB '_DEC B',1,005H,0FFH
	.DB '_DEC BC',1,00BH,0FFH
	.DB '_DEC C',1,00DH,0FFH
	.DB '_DEC D',1,015H,0FFH
	.DB '_DEC DE',1,01BH,0FFH
	.DB '_DEC E',1,01DH,0FFH
	.DB '_DEC H',1,025H,0FFH
	.DB '_DEC HL',1,02BH,0FFH

	.DB '_DEC L',1,02DH,0FFH
	.DB '_DEC SP',1,03BH,0FFH
	.DB '_DI',1,0F3H,0FFH
	.DB '_DJNZ #',1,010H,0FFH
	   
	.DB '_EI',1,0FBH,0FFH
	.DB '_EX (SP)',2CH,'HL',1,0E3H,0FFH
	.DB '_EX AF',2CH,'AF',1,008H,0FFH
	.DB '_EX DE',2CH,'HL',1,0EBH,0FFH
	.DB '_EXX',1,0D9H,0FFH

	.DB '_HALT',1,076H,0FFH
	   

	   

	   
	.DB '_IN A',2CH,'(#)',1,0DBH,0FFH
	   

	 DB '_INC (HL)',1,034H,0FFH

	.DB '_INC A',1,03CH,0FFH
	.DB '_INC B',1,004H,0FFH
	.DB '_INC BC',1,003H,0FFH
	.DB '_INC C',1,00CH,0FFH
	.DB '_INC D',1,014H,0FFH
	.DB '_INC DE',1,013H,0FFH
	.DB '_INC E',1,01CH,0FFH
	.DB '_INC H',1,024H,0FFH
	.DB '_INC HL',1,023H,0FFH

	.DB '_INC L',1,02CH,0FFH
	.DB '_INC SP',1,033H,0FFH
	   
	.DB '_JR C',2CH,'#',1,038H,0FFH
	.DB '_JR NC',2CH,'#',1,030H,0FFH
	.DB '_JR NZ',2CH,'#',1,020H,0FFH
	.DB '_JR Z',2CH,'#',1,028H,0FFH
	.DB '_JR #',1,018H,0FFH	   

	   

	.DB '_JP (HL)',1,0E9H,0FFH

	.DB '_JP C',2CH,'$',1,0DAH,0FFH
	.DB '_JP M',2CH,'$',1,0FAH,0FFH
	.DB '_JP NC',2CH,'$',1,0D2H,0FFH
	.DB '_JP NZ',2CH,'$',1,0C2H,0FFH
	.DB '_JP P',2CH,'$',1,0F2H,0FFH
	.DB '_JP PE',2CH,'$',1,0EAH,0FFH
	.DB '_JP PO',2CH,'$',1,0E2H,0FFH
	.DB '_JP Z',2CH,'$',1,0CAH,0FFH
	.DB '_JP $',1,0C3H,0FFH
	   

	   
	.DB '_LD (BC)',2CH,'A',1,002H,0FFH
	.DB '_LD (DE)',2CH,'A',1,012H,0FFH
	.DB '_LD (HL)',2CH,'A',1,077H,0FFH
	.DB '_LD (HL)',2CH,'B',1,070H,0FFH
	.DB '_LD (HL)',2CH,'C',1,071H,0FFH
	.DB '_LD (HL)',2CH,'D',1,072H,0FFH
	.DB '_LD (HL)',2CH,'E',1,073H,0FFH
	.DB '_LD (HL)',2CH,'H',1,074H,0FFH
	.DB '_LD (HL)',2CH,'L',1,075H,0FFH
	.DB '_LD (HL)',2CH,'#',1,036H,0FFH

	.DB '_LD ($)',2CH,'A',1,032H,0FFH
	.DB '_LD ($)',2CH,'HL',1,022H,0FFH
	
	
	.DB '_LD A',2CH,'(BC)',1,00AH,0FFH
	.DB '_LD A',2CH,'(DE)',1,01AH,0FFH
	.DB '_LD A',2CH,'(HL)',1,07EH,0FFH

	.DB '_LD A',2CH,'A',1,07FH,0FFH
	.DB '_LD A',2CH,'B',1,078H,0FFH
	.DB '_LD A',2CH,'C',1,079H,0FFH
	.DB '_LD A',2CH,'D',1,07AH,0FFH
	.DB '_LD A',2CH,'E',1,07BH,0FFH
	.DB '_LD A',2CH,'H',1,07CH,0FFH
	.DB '_LD A',2CH,'L',1,07DH,0FFH
	.DB '_LD A',2CH,'($)',1,03AH,0FFH
	.DB '_LD A',2CH,'#',1,03EH,0FFH             
	.DB '_LD B',2CH,'(HL)',1,046H,0FFH
	.DB '_LD B',2CH,'A',1,047H,0FFH
	.DB '_LD B',2CH,'B',1,040H,0FFH
	.DB '_LD B',2CH,'C',1,041H,0FFH
	.DB '_LD B',2CH,'D',1,042H,0FFH
	.DB '_LD B',2CH,'E',1,043H,0FFH
	.DB '_LD B',2CH,'H',1,044H,0FFH
	.DB '_LD B',2CH,'L',1,045H,0FFH
	.DB '_LD B',2CH,'#',1,006H,0FFH
	.DB '_LD BC',2CH,'$',1,001H,0FFH
	.DB '_LD C',2CH,'(HL)',1,04EH,0FFH
	.DB '_LD C',2CH,'A',1,04FH,0FFH
	.DB '_LD C',2CH,'B',1,048H,0FFH
	.DB '_LD C',2CH,'C',1,049H,0FFH
	.DB '_LD C',2CH,'D',1,04AH,0FFH
	.DB '_LD C',2CH,'E',1,04BH,0FFH
	.DB '_LD C',2CH,'H',1,04CH,0FFH
	.DB '_LD C',2CH,'L',1,04DH,0FFH
	.DB '_LD C',2CH,'#',1,00EH,0FFH
	.DB '_LD D',2CH,'(HL)',1,056H,0FFH
	.DB '_LD D',2CH,'A',1,057H,0FFH
	.DB '_LD D',2CH,'B',1,050H,0FFH
	.DB '_LD D',2CH,'C',1,051H,0FFH
	.DB '_LD D',2CH,'D',1,052H,0FFH
	.DB '_LD D',2CH,'E',1,053H,0FFH
	.DB '_LD D',2CH,'H',1,054H,0FFH
	.DB '_LD D',2CH,'L',1,055H,0FFH
	.DB '_LD D',2CH,'#',1,016H,0FFH
	.DB '_LD DE',2CH,'$',1,011H,0FFH
	.DB '_LD E',2CH,'(HL)',1,05EH,0FFH
	.DB '_LD E',2CH,'A',1,05FH,0FFH
	.DB '_LD E',2CH,'B',1,058H,0FFH
	.DB '_LD E',2CH,'C',1,059H,0FFH
	.DB '_LD E',2CH,'D',1,05AH,0FFH
	.DB '_LD E',2CH,'E',1,05BH,0FFH
	.DB '_LD E',2CH,'H',1,05CH,0FFH
	.DB '_LD E',2CH,'L',1,05DH,0FFH
	.DB '_LD E',2CH,'#',1,01EH,0FFH
	.DB '_LD H',2CH,'(HL)',1,066H,0FFH
	.DB '_LD H',2CH,'A',1,067H,0FFH
	.DB '_LD H',2CH,'B',1,060H,0FFH
	.DB '_LD H',2CH,'C',1,061H,0FFH
	.DB '_LD H',2CH,'D',1,062H,0FFH
	.DB '_LD H',2CH,'E',1,063H,0FFH
	.DB '_LD H',2CH,'H',1,064H,0FFH
	.DB '_LD H',2CH,'L',1,065H,0FFH
	.DB '_LD H',2CH,'#',1,026H,0FFH
	.DB '_LD HL',2CH,'($)',1,02AH,0FFH
	.DB '_LD HL',2CH,'$',1,021H,0FFH
	.DB '_LD L',2CH,'(HL)',1,06EH,0FFH
	.DB '_LD L',2CH,'A',1,06FH,0FFH
	.DB '_LD L',2CH,'B',1,068H,0FFH
	.DB '_LD L',2CH,'C',1,069H,0FFH
	.DB '_LD L',2CH,'D',1,06AH,0FFH
	.DB '_LD L',2CH,'E',1,06BH,0FFH
	.DB '_LD L',2CH,'H',1,06CH,0FFH
	.DB '_LD L',2CH,'L',1,06DH,0FFH
	.DB '_LD L',2CH,'#',1,02EH,0FFH
	.DB '_LD SP',2CH,'$',1,031H,0FFH
	.DB '_LD SP',2CH,'HL',1,0F9H,0FFH
	
	
			



	

	.DB '_NOP',1,000H,0FFH
   
	.DB '_OR (HL)',1,0B6H,0FFH

	.DB '_OR A',1,0B7H,0FFH
	.DB '_OR B',1,0B0H,0FFH
	.DB '_OR C',1,0B1H,0FFH
	.DB '_OR D',1,0B2H,0FFH
	.DB '_OR E',1,0B3H,0FFH
	.DB '_OR H',1,0B4H,0FFH
	.DB '_OR L',1,0B5H,0FFH
	.DB '_OR #',1,0F6H,0FFH
	   

	.DB '_OUT (#)',2CH,'A',1,0D3H,0FFH
	   
	   

	   
	.DB '_POP AF',1,0F1H,0FFH
	.DB '_POP BC',1,0C1H,0FFH
	.DB '_POP DE',1,0D1H,0FFH
	.DB '_POP HL',1,0E1H,0FFH

	   
	.DB '_PUSH AF',1,0F5H,0FFH
	.DB '_PUSH BC',1,0C5H,0FFH
	.DB '_PUSH DE',1,0D5H,0FFH
	.DB '_PUSH HL',1,0E5H,0FFH

	   
	.DB '_RET',1,0C9H,0FFH
	.DB '_RET C',1,0D8H,0FFH
	.DB '_RET M',1,0F8H,0FFH
	.DB '_RET NC',1,0D0H,0FFH
	.DB '_RET NZ',1,0C0H,0FFH
	.DB '_RET P',1,0F0H,0FFH
	.DB '_RET PE',1,0E8H,0FFH
	.DB '_RET PO',1,0E0H,0FFH
	.DB '_RET Z',1,0C8H,0FFH

	.DB '_RLA',1,017H,0FFH
	   

	   

	.DB '_RLCA',1,007H,0FFH
	.DB '_RRA',1,01FH,0FFH

	.DB '_RRCA',1,00FH,0FFH

   
	.DB '_RST 00',1,0C7H,0FFH
	.DB '_RST 08',1,0CFH,0FFH
	.DB '_RST 10',1,0D7H,0FFH
	.DB '_RST 18',1,0DFH,0FFH
	.DB '_RST 20',1,0E7H,0FFH
	.DB '_RST 28',1,0EFH,0FFH
	.DB '_RST 30',1,0F7H,0FFH
	.DB '_RST 38',1,0FFH,0FFH
	   
	.DB '_SBC A',2CH,'(HL)',1,09EH,0FFH

	.DB '_SBC A',2CH,'A',1,09FH,0FFH
	.DB '_SBC A',2CH,'B',1,098H,0FFH
	.DB '_SBC A',2CH,'C',1,099H,0FFH
	.DB '_SBC A',2CH,'D',1,09AH,0FFH
	.DB '_SBC A',2CH,'E',1,09BH,0FFH
	.DB '_SBC A',2CH,'H',1,09CH,0FFH
	.DB '_SBC A',2CH,'L',1,09DH,0FFH

	.DB '_SBC A',2CH,'#',1,0DEH,0FFH
	
	.DB '_SCF',1,037H,0FFH
	   

	   	   

   
	.DB '_SUB (HL)',1,096H,0FFH

	.DB '_SUB A',1,097H,0FFH
	.DB '_SUB B',1,090H,0FFH
	.DB '_SUB C',1,091H,0FFH
	.DB '_SUB D',1,092H,0FFH
	.DB '_SUB E',1,093H,0FFH
	.DB '_SUB H',1,094H,0FFH
	.DB '_SUB L',1,095H,0FFH
	.DB '_SUB #',1,0D6H,0FFH
	   
	   
	.DB '_XOR (HL)',1,0AEH,0FFH

	.DB '_XOR A',1,0AFH,0FFH
	.DB '_XOR B',1,0A8H,0FFH
	.DB '_XOR C',1,0A9H,0FFH
	.DB '_XOR D',1,0AAH,0FFH
	.DB '_XOR E',1,0ABH,0FFH
	.DB '_XOR H',1,0ACH,0FFH
	.DB '_XOR L',1,0ADH,0FFH
	.DB '_XOR #',1,0EEH,0FFH
	
AFTERCOD:
	.DB '_ADC A',2CH,'(IX+#)',2,0DDH,08EH
	.DB '_ADC A',2CH,'(IY+#)',2,0FDH,08EH
	.DB '_ADC HL',2CH,'BC',2,0EDH,04AH
	.DB '_ADC HL',2CH,'DE',2,0EDH,05AH
	.DB '_ADC HL',2CH,'HL',2,0EDH,06AH
	.DB '_ADC HL',2CH,'SP',2,0EDH,07AH
	.DB '_ADD A',2CH,'(IX+#)',2,0DDH,086H
	.DB '_ADD A',2CH,'(IY+#)',2,0FDH,086H
	.DB '_ADD IX',2CH,'BC',2,0DDH,009H
	.DB '_ADD IX',2CH,'DE',2,0DDH,019H
	.DB '_ADD IX',2CH,'IX',2,0DDH,029H
	.DB '_ADD IX',2CH,'SP',2,0DDH,039H
	.DB '_ADD IY',2CH,'BC',2,0FDH,009H
	.DB '_ADD IY',2CH,'DE',2,0FDH,019H
	.DB '_ADD IY',2CH,'IY',2,0FDH,029H
	.DB '_ADD IY',2CH,'SP',2,0FDH,039H
	.DB '_AND (IX+#)',2,0DDH,0A6H
	.DB '_AND (IY+#)',2,0FDH,0A6H
	.DB '_BIT #',2CH,'(HL)',2,0CBH,046H
	.DB '_BIT #',2CH,'A',2,0CBH,047H
	.DB '_BIT #',2CH,'B',2,0CBH,040H
	.DB '_BIT #',2CH,'C',2,0CBH,041H
	.DB '_BIT #',2CH,'D',2,0CBH,042H
	.DB '_BIT #',2CH,'E',2,0CBH,043H
	.DB '_BIT #',2CH,'H',2,0CBH,044H
	.DB '_BIT #',2CH,'L',2,0CBH,045H
	.DB '_CP (IX+#)',2,0DDH,0BEH
	.DB '_CP (IY+#)',2,0FDH,0BEH
	.DB '_CPD',2,0EDH,0A9H	;BASLANGICI BENZER KOMUTLARDA TABLODA ONCE KISA OLAN OLMALI
	.DB '_CPDR',2,0EDH,0B9H
	.DB '_CPI',2,0EDH,0A1H
	.DB '_CPIR',2,0EDH,0B1H
	.DB '_DEC (IX+#)',2,0DDH,035H
	.DB '_DEC (IY+#)',2,0FDH,035H
	.DB '_DEC IX',2,0DDH,02BH
	.DB '_DEC IY',2,0FDH,02BH

	.DB '_EX (SP)',2CH,'IX',2,0DDH,0E3H
	.DB '_EX (SP)',2CH,'IY',2,0FDH,0E3H

	.DB '_IM0',2,0EDH,046H
	.DB '_IM1',2,0EDH,056H
	.DB '_IM2',2,0EDH,05EH
	.DB '_IN A',2CH,'(C)',2,0EDH,078H
	.DB '_IN B',2CH,'(C)',2,0EDH,040H
	.DB '_IN C',2CH,'(C)',2,0EDH,048H
	.DB '_IN D',2CH,'(C)',2,0EDH,050H
	.DB '_IN E',2CH,'(C)',2,0EDH,058H
	.DB '_IN H',2CH,'(C)',2,0EDH,060H
	.DB '_IN L',2CH,'(C)',2,0EDH,068H
	.DB '_INC (IX+#)',2,0DDH,034H
	.DB '_INC (IY+#)',2,0FDH,034H
	.DB '_IND',2,0EDH,0AAH
	.DB '_INDR',2,0EDH,0BAH
	.DB '_INI',2,0EDH,0A2H
	.DB '_INIR',2,0EDH,0B2H
	.DB '_INC IX',2,0DDH,023H
	.DB '_INC IY',2,0FDH,023H
	
	.DB '_JP (IX+#)',2,0DDH,0E9H
	.DB '_JP (IY+#)',2,0FDH,0E9H
	

	.DB '_LD (IX+#)',2CH,'A',2,0DDH,077H
	.DB '_LD (IX+#)',2CH,'B',2,0DDH,070H
	.DB '_LD (IX+#)',2CH,'C',2,0DDH,071H
	.DB '_LD (IX+#)',2CH,'D',2,0DDH,072H
	.DB '_LD (IX+#)',2CH,'E',2,0DDH,073H
	.DB '_LD (IX+#)',2CH,'H',2,0DDH,074H
	.DB '_LD (IX+#)',2CH,'L',2,0DDH,075H
	.DB '_LD (IY+#)',2CH,'A',2,0FDH,077H
	.DB '_LD (IY+#)',2CH,'B',2,0FDH,070H
	.DB '_LD (IY+#)',2CH,'C',2,0FDH,071H
	.DB '_LD (IY+#)',2CH,'D',2,0FDH,072H
	.DB '_LD (IY+#)',2CH,'E',2,0FDH,073H
	.DB '_LD (IY+#)',2CH,'H',2,0FDH,074H
	.DB '_LD (IY+#)',2CH,'L',2,0FDH,075H
	.DB '_LD ($)',2CH,'BC',2,0EDH,043H
	.DB '_LD ($)',2CH,'DE',2,0EDH,053H
	.DB '_LD ($)',2CH,'IX',2,0DDH,022H
	.DB '_LD ($)',2CH,'IY',2,0FDH,022H
	.DB '_LD ($)',2CH,'SP',2,0EDH,073H
	.DB '_LD A',2CH,'(IX+#)',2,0DDH,07EH
	.DB '_LD A',2CH,'(IY+#)',2,0FDH,07EH
	.DB '_LD A',2CH,'I',2,0EDH,057H
	.DB '_LD A',2CH,'R',2,0EDH,05FH
	.DB '_LD B',2CH,'(IX+#)',2,0DDH,046H
	.DB '_LD B',2CH,'(IY+#)',2,0FDH,046H
	.DB '_LD BC',2CH,'($)',2,0EDH,04BH
	.DB '_LD C',2CH,'(IX+#)',2,0DDH,04EH
	.DB '_LD C',2CH,'(IY+#)',2,0FDH,04EH
	.DB '_LD D',2CH,'(IX+#)',2,0DDH,056H
	.DB '_LD D',2CH,'(IY+#)',2,0FDH,056H
	.DB '_LD DE',2CH,'($)',2,0EDH,05BH
	.DB '_LD E',2CH,'(IX+#)',2,0DDH,05EH
	.DB '_LD E',2CH,'(IY+#)',2,0FDH,05EH
	.DB '_LD H',2CH,'(IX+#)',2,0DDH,066H
	.DB '_LD H',2CH,'(IY+#)',2,0FDH,066H
	.DB '_LD I',2CH,'A',2,0EDH,047H
	.DB '_LD IX',2CH,'($)',2,0DDH,02AH
	.DB '_LD IX',2CH,'$',2,0DDH,021H
	.DB '_LD IY',2CH,'($)',2,0FDH,02AH
	.DB '_LD IY',2CH,'$',2,0FDH,021H
	.DB '_LD L',2CH,'(IX+#)',2,0DDH,06EH
	.DB '_LD L',2CH,'(IY+#)',2,0FDH,06EH
	.DB '_LD R',2CH,'A',2,0EDH,04FH
	.DB '_LD SP',2CH,'($)',2,0EDH,07BH
	.DB '_LD SP',2CH,'IX',2,0DDH,0F9H
	.DB '_LD SP',2CH,'IY',2,0FDH,0F9H
	.DB '_LDD',2,0EDH,0A8H
	.DB '_LDDR',2,0EDH,0B8H
	.DB '_LDI',2,0EDH,0A0H
	.DB '_LDIR',2,0EDH,0B0H
	.DB '_NEG',2,0EDH,044H
	.DB '_OR (IX+#)',2,0DDH,0B6H
	.DB '_OR (IY+#)',2,0FDH,0B6H
	.DB '_OTDR',2,0EDH,0BBH
	.DB '_OTIR',2,0EDH,0B3H
	   
	.DB '_OUT (C)',2CH,'A',2,0EDH,079H
	.DB '_OUT (C)',2CH,'B',2,0EDH,041H
	.DB '_OUT (C)',2CH,'C',2,0EDH,049H
	.DB '_OUT (C)',2CH,'D',2,0EDH,051H
	.DB '_OUT (C)',2CH,'E',2,0EDH,059H
	.DB '_OUT (C)',2CH,'H',2,0EDH,061H
	.DB '_OUT (C)',2CH,'L',2,0EDH,069H
	.DB '_OUTD',2,0EDH,0ABH
	.DB '_OUTI',2,0EDH,0A3H
	.DB '_POP IX',2,0DDH,0E1H
	.DB '_POP IY',2,0FDH,0E1H
	.DB '_PUSH IX',2,0DDH,0E5H
	.DB '_PUSH IY',2,0FDH,0E5H
	   
	.DB '_RES #',2CH,'(HL)',2,0CBH,086H
;	.DB '_RES #',2CH,'(IX+#)',3,0DDH,0CBH ;DEFAULT 2
;	.DB '_RES #',2CH,'(IY+#)',2,0FDH,0CBH
	.DB '_RES #',2CH,'A',2,0CBH,087H
	.DB '_RES #',2CH,'B',2,0CBH,080H
	.DB '_RES #',2CH,'C',2,0CBH,081H
	.DB '_RES #',2CH,'D',2,0CBH,082H
	.DB '_RES #',2CH,'E',2,0CBH,083H
	.DB '_RES #',2CH,'H',2,0CBH,084H
	.DB '_RES #',2CH,'L',2,0CBH,085H
	.DB '_RETI',2,0EDH,04DH
	.DB '_RETN',2,0EDH,045H
	   
	.DB '_RL (HL)',2,0CBH,016H
	.DB '_RL (IX+#)',2,0DDH,0CBH
	.DB '_RL (IY+#)',2,0FDH,0CBH
	.DB '_RL A',2,0CBH,017H
	.DB '_RL B',2,0CBH,010H
	.DB '_RL C',2,0CBH,011H
	.DB '_RL D',2,0CBH,012H
	.DB '_RL E',2,0CBH,013H
	.DB '_RL H',2,0CBH,014H
	.DB '_RL L',2,0CBH,015H
	.DB '_RLC (HL)',2,0CBH,006H
	.DB '_RLC (IX+#)',2,0DDH,0CBH
	.DB '_RLC (IY+#)',2,0FDH,0CBH
	.DB '_RLC A',2,0CBH,007H
	.DB '_RLC B',2,0CBH,000H
	.DB '_RLC C',2,0CBH,001H
	.DB '_RLC D',2,0CBH,002H
	.DB '_RLC E',2,0CBH,003H
	.DB '_RLC H',2,0CBH,004H
	.DB '_RLC L',2,0CBH,005H
	.DB '_RLD',2,0EDH,06FH
	.DB '_RRD',2,0EDH,067H
	.DB '_RR (HL)',2,0CBH,01EH
	.DB '_RR (IX+#)',2,0DDH,0CBH
	.DB '_RR (IY+#)',2,0FDH,0CBH
	.DB '_RR A',2,0CBH,01FH
	.DB '_RR B',2,0CBH,018H
	.DB '_RR C',2,0CBH,019H
	.DB '_RR D',2,0CBH,01AH
	.DB '_RR E',2,0CBH,01BH
	.DB '_RR H',2,0CBH,01CH
	.DB '_RR L',2,0CBH,01DH
	.DB '_RRC (HL)',2,0CBH,00EH
	.DB '_RRC (IX+#)',2,0DDH,0CBH
	.DB '_RRC (IY+#)',2,0FDH,0CBH
	.DB '_RRC A',2,0CBH,00FH
	.DB '_RRC B',2,0CBH,008H
	.DB '_RRC C',2,0CBH,009H
	.DB '_RRC D',2,0CBH,00AH
	.DB '_RRC E',2,0CBH,00BH
	.DB '_RRC H',2,0CBH,00CH
	.DB '_RRC L',2,0CBH,00DH
	
	.DB '_SBC A',2CH,'(IX+#)',2,0DDH,09EH
	.DB '_SBC A',2CH,'(IY+#)',2,0FDH,09EH
	.DB '_SBC HL',2CH,'BC',2,0EDH,042H
	.DB '_SBC HL',2CH,'DE',2,0EDH,052H
	.DB '_SBC HL',2CH,'HL',2,0EDH,062H
	.DB '_SBC HL',2CH,'SP',2,0EDH,072H
	.DB '_SET #',2CH,'(HL)',2,0CBH,0C6H
	.DB '_SET #',2CH,'(IX+#)',2,0DDH,0CBH
	.DB '_SET #',2CH,'(IY+#)',2,0FDH,0CBH
	.DB '_SET #',2CH,'A',2,0CBH,0C7H
	.DB '_SET #',2CH,'B',2,0CBH,0C0H
	.DB '_SET #',2CH,'C',2,0CBH,0C1H
	.DB '_SET #',2CH,'D',2,0CBH,0C2H
	.DB '_SET #',2CH,'E',2,0CBH,0C3H
	.DB '_SET #',2CH,'H',2,0CBH,0C4H
	.DB '_SET #',2CH,'L',2,0CBH,0C5H
   
	.DB '_SLA (HL)',2,0CBH,026H
	.DB '_SLA (IX+#)',2,0DDH,0CBH
	.DB '_SLA (IY+#)',2,0FDH,0CBH
	.DB '_SLA A',2,0CBH,027H
	.DB '_SLA B',2,0CBH,020H
	.DB '_SLA C',2,0CBH,021H
	.DB '_SLA D',2,0CBH,022H
	.DB '_SLA E',2,0CBH,023H
	.DB '_SLA H',2,0CBH,024H
	.DB '_SLA L',2,0CBH,025H
	.DB '_SRA (HL)',2,0CBH,02EH
	.DB '_SRA (IX+#)',2,0DDH,0CBH
	.DB '_SRA (IY+#)',2,0FDH,0CBH
	.DB '_SRA A',2,0CBH,02FH
	.DB '_SRA B',2,0CBH,028H
	.DB '_SRA C',2,0CBH,029H
	.DB '_SRA D',2,0CBH,02AH
	.DB '_SRA E',2,0CBH,02BH
	.DB '_SRA H',2,0CBH,02CH
	.DB '_SRA L',2,0CBH,02DH
	   
	.DB '_SRL (HL)',2,0CBH,03EH
	.DB '_SRL (IX+#)',2,0DDH,0CBH
	.DB '_SRL (IY+#)',2,0FDH,0CBH
	.DB '_SRL A',2,0CBH,03FH
	.DB '_SRL B',2,0CBH,038H
	.DB '_SRL C',2,0CBH,039H
	.DB '_SRL D',2,0CBH,03AH
	.DB '_SRL E',2,0CBH,03BH
	.DB '_SRL H',2,0CBH,03CH
	.DB '_SRL L',2,0CBH,03DH
	.DB '_SUB (IX+#)',2,0DDH,096H
	.DB '_SUB (IY+#)',2,0FDH,096H

	.DB '_XOR (IX+#)',2,0DDH,0AEH
	.DB '_XOR (IY+#)',2,0FDH,0AEH

;SIK KULLANILAN SUBRUTIN VE KOD ADRESLERI KOMUT OLARAK ASSEMBLER'A EKLENEBILIR!	

    .DB '_CALL TXD',3,0CDH
    .DW TXD

	.DB '_CALL RXD',3,0CDH
    .DW RXD

	.DB '_CALL PRINT',3,0CDH
    .DW PRINT

	.DB '_CALL HEXOUT',3,0CDH
    .DW HEXOUT

	.DB '_CALL DELAY',3,0CDH
    .DW DELAY_1S

	.DB '_JP PROMPT',3,0C3H
    .DW INPUT

	.DB '_JP Z, PROMPT',3,0CAH
    .DW INPUT	

	.DB '_JP NZ, PROMPT',3,0C2H
    .DW INPUT

	.DB '_CALL BYTEIN',3,0CDH
    .DW BYTEIN1

	.DB '_CALL WORDIN',3,0CDH
    .DW BYTEIN2

	.DB '_CALL CRLF',3,0CDH
    .DW CRLF		




    

	.DB 0,0,0,0,0,0,0,0
	.DB 0,0,0,0,0,0,0,0
CODEND:	.DB 0,0,0,0,0,0,0,0
	.DB 0,0,0,0,0,0,0,0


	
	
	

	
		

	.END
