unit Agenda;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.StdCtrls,
  FMX.Controls.Presentation, FMX.Edit, FMX.ListView.Types,
  FMX.ListView.Appearances, FMX.ListView.Adapters.Base, FMX.ListView, Data.DB,
  MemDS, DBAccess, MyAccess, System.Rtti, System.Bindings.Outputs,
  Fmx.Bind.Editors, Data.Bind.EngExt, Fmx.Bind.DBEngExt, Data.Bind.Components,
  Data.Bind.DBScope, FMX.Layouts, FMX.ExtCtrls, FMX.Objects;

type
  TForm1 = class(TForm)
    edtTel: TEdit;
    Salvar: TButton;
    ListViewContatos: TListView;
    connAgenda: TMyConnection;
    qryContatos: TMyQuery;
    BindSourceDB1: TBindSourceDB;
    BindingsList1: TBindingsList;
    LinkControlToField2: TLinkControlToField;
    Novo: TButton;
    Excluir: TButton;
    LinkListControlToField1: TLinkListControlToField;
    edtNome: TEdit;
    LinkControlToField3: TLinkControlToField;
    Z: TRectangle;
    StyleBook1: TStyleBook;
    Telefone: TLabel;
    Cancelar: TButton;
    Label3: TLabel;
    Timer1: TTimer;
    procedure NovoClick(Sender: TObject);
    procedure ExcluirClick(Sender: TObject);
    procedure SalvarClick(Sender: TObject);
    procedure qryContatosBeforePost(DataSet: TDataSet);
    procedure CancelarClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation

{$R *.fmx}
{$R *.LgXhdpiPh.fmx ANDROID}
{$R *.Windows.fmx MSWINDOWS}
{$R *.NmXhdpiPh.fmx ANDROID}

procedure TForm1.NovoClick(Sender: TObject);
begin
  // Se o usuário começou a alterar um contato sem querer, cancela a alteração
  if qryContatos.State in [dsInsert, dsEdit] then
    qryContatos.Cancel;

  // Abre uma linha totalmente nova e limpa para a digitação
  qryContatos.Append;
end;

procedure TForm1.qryContatosBeforePost(DataSet: TDataSet);
begin
  // Acessa o valor do campo "nome" direto do que está na memória
  if Trim(DataSet.FieldByName('nome').AsString) = '' then
  begin
    // Cancela a inserção da linha em branco, fazendo ela sumir da memória
    DataSet.Cancel;

    // O comando Abort joga uma exceção silenciosa. Ele para a execução do
    // auto-save sem mostrar nenhuma janela de erro de sistema para o usuário final!
    Abort;
  end;
end;

procedure TForm1.CancelarClick(Sender: TObject);
begin
  // Verifica se o banco está em modo de edição ou inserção
  if qryContatos.State in [dsInsert, dsEdit] then
  begin
    // O Cancel destrói a linha nova ou reverte os TEdits para o valor original do banco
    qryContatos.Cancel;
    ShowMessage('Alteração desfeita.');
  end;
end;

procedure TForm1.ExcluirClick(Sender: TObject);
begin
  if not qryContatos.IsEmpty then
    qryContatos.Delete; // Deleta a linha selecionada no momento
end;

procedure TForm1.FormCreate(Sender: TObject);
begin
  // Timer liga para TODOS (Windows e Android)
  // Como as propriedades visuais estão False, o app abre instantaneamente
  Timer1.Enabled := True;
end;

procedure TForm1.SalvarClick(Sender: TObject);
begin
  // 1. Validação: Verifica se o campo Nome está vazio
  // O comando Trim remove espaços em branco extras caso o usuário digite só "espaço"
  if Trim(edtNome.Text) = '' then
  begin
    ShowMessage('Por favor, preencha o Nome antes de salvar.');

    // Se era uma linha nova que ficou vazia, cancelamos para não travar o banco
    if qryContatos.State in [dsInsert, dsEdit] then
      qryContatos.Cancel;

    Exit; // Para a execução aqui. O código não desce para a linha de salvar.
  end;

  // 2. Salvamento: Se o código chegou até aqui, é porque o nome está preenchido!
  if qryContatos.State in [dsInsert, dsEdit] then
    qryContatos.Post;
end;

procedure TForm1.Timer1Timer(Sender: TObject);
begin
  // Desliga a si mesmo
  Timer1.Enabled := False;

  try
    // Se estiver no Android, ajusta o IP e força o modo Direct
    {$IFDEF ANDROID}
    connAgenda.Server := '192.168.15.26';

    connAgenda.Username := 'app';
    connAgenda.Password := '1234';

    connAgenda.Options.Direct := True;
    {$ENDIF}

    // Se estiver no Windows, ele vai ignorar o bloco acima e usar o "localhost"
    // que já está configurado no seu componente.

    // Agora sim, com a tela já aberta, ele conecta!
    connAgenda.Connected := True;
    qryContatos.Open;

  except
    on E: Exception do
      ShowMessage('Erro ao conectar: ' + E.Message);
  end;
end;

end.
