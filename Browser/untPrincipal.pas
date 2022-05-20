unit untPrincipal;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.Menus, Vcl.ComCtrls, Vcl.ToolWin,
  Vcl.ImgList, Vcl.StdCtrls, Vcl.OleCtrls, SHDocVw, Registry;

type
  TfrmPrincipal = class(TForm)
    ImageList1: TImageList;
    CoolBar1: TCoolBar;
    ToolBar1: TToolBar;
    btnVoltar: TToolButton;
    btnAvancar: TToolButton;
    btnParar: TToolButton;
    btnAtualizar: TToolButton;
    ToolButton1: TToolButton;
    btnHome: TToolButton;
    btnPesquisa: TToolButton;
    ComboBox1: TComboBox;
    StatusBar1: TStatusBar;
    WebBrowser1: TWebBrowser;
    ProgressBar1: TProgressBar;
    MainMenu1: TMainMenu;
    Sair1: TMenuItem;
    procedure btnVoltarClick(Sender: TObject);
    procedure btnAvancarClick(Sender: TObject);
    procedure btnPararClick(Sender: TObject);
    procedure btnAtualizarClick(Sender: TObject);
    procedure btnHomeClick(Sender: TObject);
    procedure btnPesquisaClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure WebBrowser1ProgressChange(ASender: TObject; Progress,
      ProgressMax: Integer);
    procedure WebBrowser1CommandStateChange(ASender: TObject; Command: Integer;
      Enable: WordBool);
    procedure WebBrowser1BeforeNavigate2(ASender: TObject;
      const pDisp: IDispatch; const URL, Flags, TargetFrameName, PostData,
      Headers: OleVariant; var Cancel: WordBool);
    procedure ComboBox1KeyPress(Sender: TObject; var Key: Char);
    procedure WebBrowser1StatusTextChange(ASender: TObject;
      const Text: WideString);
    procedure WebBrowser1TitleChange(ASender: TObject; const Text: WideString);
    procedure Sair1Click(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
  private
    { Private declarations }
    Procedure ExibirURLsVisitadas(Urls: TStrings);
  public
    { Public declarations }
  end;

var
  frmPrincipal: TfrmPrincipal;

implementation

{$R *.dfm}

procedure TfrmPrincipal.btnAtualizarClick(Sender: TObject);
begin
  WebBrowser1.Refresh;
end;

procedure TfrmPrincipal.btnAvancarClick(Sender: TObject);
begin
  WebBrowser1.GoForward;
end;

procedure TfrmPrincipal.btnHomeClick(Sender: TObject);
begin
  WebBrowser1.GoHome;
end;

procedure TfrmPrincipal.btnPararClick(Sender: TObject);
begin
  WebBrowser1.Stop;
end;

procedure TfrmPrincipal.btnPesquisaClick(Sender: TObject);
begin
  WebBrowser1.GoSearch;
end;

procedure TfrmPrincipal.btnVoltarClick(Sender: TObject);
begin
  WebBrowser1.GoBack;
end;

procedure TfrmPrincipal.ComboBox1KeyPress(Sender: TObject; var Key: Char);
begin
  //Se a tecla pressionada for Enter, ent�o navegue at� a //p�gina tal.
  if (key=#13) then
  begin
    webbrowser1.Navigate(combobox1.Text);
  end;
end;

procedure TfrmPrincipal.ExibirURLsVisitadas(Urls: TStrings);
var
  Reg: TRegistry;
  S: TStringList;
  i: Integer;
begin
  Reg := TRegistry.Create;
  try
    Reg.RootKey := HKEY_CURRENT_USER;
    if Reg.OpenKey('Software\Microsoft\Internet Explorer\TypedURLs', False) then
    begin
      S := TStringList.Create;
      try
        reg.GetValueNames(S);
        for i := 0 to S.Count - 1 do
        begin
          Urls.Add(reg.ReadString(S.Strings[i]));
        end;
      finally
        S.Free;
      end;
      Reg.CloseKey;
    end;
  finally
    Reg.Free;
  end;
end;

procedure TfrmPrincipal.FormCreate(Sender: TObject);
begin
  WebBrowser1.GoHome;
  ExibirURLsVisitadas(ComboBox1.Items);
end;

procedure TfrmPrincipal.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if Key = VK_F5 then
    WebBrowser1.Refresh;
end;

procedure TfrmPrincipal.FormResize(Sender: TObject);
var
  r: TRect;
const
  SB_GETRECT = WM_USER + 10;
begin
  // Definindo onde ficar� a progressbar, neste caso ser�
  //Na barra de Status, no painel 1
  Statusbar1.Perform(SB_GETRECT, 1, Integer(@R));
  ProgressBar1.Parent := Statusbar1;
  ProgressBar1.SetBounds(r.Left, r.Top,r.Right - r.Left - 5,r.Bottom - r.Top);
end;

procedure TfrmPrincipal.Sair1Click(Sender: TObject);
begin
  Application.Terminate;
end;

procedure TfrmPrincipal.WebBrowser1BeforeNavigate2(ASender: TObject;
  const pDisp: IDispatch; const URL, Flags, TargetFrameName, PostData,
  Headers: OleVariant; var Cancel: WordBool);

begin
  {Ao Nevagar uma p�gina, ele coloca automaticamente
  o endere�o dela no combobox, para sabermos que p�gina
  estamos entrando, o endere�o da mesma}
  combobox1.Text:=url;
end;

procedure TfrmPrincipal.WebBrowser1CommandStateChange(ASender: TObject;
  Command: Integer; Enable: WordBool);
begin
  case Command of
    CSC_NAVIGATEBACK:
    begin
      //Ativa e Desativa Automaticamente o Bot�o Voltar,
      //Caso tenha alguma p�gina para voltar
      BtnVoltar.Enabled := Enable;
    end;
    CSC_NAVIGATEFORWARD:
    begin
      //Ativa e Desativa Automaticamente o Bot�o Avan�ar,
      //Caso tenha alguma p�gina para avan�ar
      BtnAvancar.Enabled := Enable;
    end;
  end;
end;

procedure TfrmPrincipal.WebBrowser1ProgressChange(ASender: TObject; Progress,
  ProgressMax: Integer);
begin
  {Ele faz um rotina para saber se o valor Maximo do
  Progressbar � maior que 1 e o valor minimo tambem
  se for, ent�o ele faz a rotina}
  if (Progress>=1) and (ProgressMax>1) then
  begin
    //Ele tira uma valor percentual para colocar
    //no Progressbar
    ProgressBar1.Position := Round((Progress * 100) Div ProgressMax);
    ProgressBar1.Visible := True;
  end
  else
  begin
    ProgressBar1.Position := 1;
    ProgressBar1.Visible := False;
  end;
end;

procedure TfrmPrincipal.WebBrowser1StatusTextChange(ASender: TObject;
  const Text: WideString);
begin
  StatusBar1.Panels[0].Text:=text;
end;

procedure TfrmPrincipal.WebBrowser1TitleChange(ASender: TObject;
  const Text: WideString);
begin
  {Colocar o nome da p�gina + ' - Kennedy Tedesco', pode trocar Kennedy Tedesco por seu nome}
  frmPrincipal.Caption:=text + ' - Neto Fiamenghi';
end;

end.
