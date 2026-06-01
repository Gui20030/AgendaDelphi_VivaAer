program Agenda_VivaAer;

uses
  System.StartUpCopy,
  FMX.Forms,
  Agenda in 'Agenda.pas' {Form1};

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TForm1, Form1);
  Application.Run;
end.
