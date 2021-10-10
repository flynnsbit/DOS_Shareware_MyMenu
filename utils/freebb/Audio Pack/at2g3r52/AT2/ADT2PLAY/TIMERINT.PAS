unit TimerInt;
interface

const
  _debug_str_: String = '';

procedure TimerSetup(Hz: Longint);
procedure TimerDone;
procedure TimerInstallHandler(handler: Pointer);
procedure TimerRemoveHandler;

implementation

uses DOS;

var
  oldint08: {$IFDEF __TMT__} FarPointer
            {$ELSE} Pointer
            {$ENDIF};
var
  newint08: Pointer;
  counter,
  clock_ticks,clock_flag: Word;
  ticks: Longint;

const
  timer_handler: Pointer = NIL;

procedure int08; interrupt;
          assembler;
asm
{$IFNDEF _32BIT}
        cmp     word ptr timer_handler,0
        jnz     @@1
        cmp     word ptr timer_handler+2,0
        jz      @@2
@@1:    push    ds
        call    [timer_handler]
        pop     ds
@@2:    mov     ax,word ptr ticks
        mov     bx,word ptr ticks+2
        add     ax,1
        adc     bx,0
        mov     word ptr ticks,ax
        mov     word ptr ticks+2,bx
        inc     clock_ticks
        mov     ax,clock_ticks
        cmp     ax,clock_flag
        jb      @@3
        mov     clock_ticks,0
        pushf
        call    [oldint08]
        jmp     @@ret
@@3:    mov     al,60h
        out     20h,al
{$ELSE}
        cmp     timer_handler,0
        jz      @@1
        push    ds
        push    es
        call    [timer_handler]
        pop     es
        pop     ds
@@1:    inc     ticks
        inc     clock_ticks
        mov     ax,clock_ticks
        cmp     ax,clock_flag
        jnz     @@2
        mov     clock_ticks,0
        pushfd
        call    [oldint08]
        jmp     @@ret
@@2:    mov     al,60h
        out     20h,al
{$ENDIF}
@@ret:
end;

procedure DisableTimerIRQ; assembler;
asm
        in      al,21h
        or      al,1
        out     21h,al
end;

procedure EnableTimerIRQ; assembler;
asm
        in      al,21h
        and     al,0feh
        out     21h,al
end;

procedure TimerSetup(Hz: Longint);
begin
  _debug_str_ := 'TIMERINT.PAS:TimerSetup';
  If (Hz < 19) then Hz := 19;
  If (Hz > 1193180) then Hz := 1193180;

  counter := 1193180 DIV Hz;
  clock_flag := Hz*1000 DIV 18206;
  newint08 := @int08;
  ticks := 0;
  clock_ticks := 0;

  DisableTimerIRQ;
  asm
        mov     al,36h
        out     43h,al
        mov     bx,counter
        mov     al,bl
        out     40h,al
        mov     al,bh
        out     40h,al
  end;

  SetIntVec($08,newint08);
  EnableTimerIRQ;
end;

procedure TimerDone;
begin
  _debug_str_ := 'TIMERINT.PAS:TimerDone';
  DisableTimerIRQ;
  asm
        mov     al,36h
        out     43h,al
        xor     ax,ax
        out     40h,al
        out     40h,al
  end;

  SetIntVec($08,oldint08);
  EnableTimerIRQ;
end;

procedure TimerInstallHandler(handler: Pointer);
begin
  _debug_str_ := 'TIMERINT.PAS:TimerInstallHandler';
  DisableTimerIRQ;
  timer_handler := handler;
  EnableTimerIRQ;
end;

procedure TimerRemoveHandler;
begin
  _debug_str_ := 'TIMERINT.PAS:TimerRemoveHandler';
  DisableTimerIRQ;
  timer_handler := NIL;
  EnableTimerIRQ;
end;

begin
  GetIntVec($08,oldint08);
end.
