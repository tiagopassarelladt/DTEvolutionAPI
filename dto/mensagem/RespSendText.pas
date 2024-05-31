unit RespSendText;

interface
  uses 
    System.SysUtils,
    Generics.Collections,
    REST.Json.Types,
    Rest.Json;

type

  TExtendedTextMessage = class
  private
    FText: string;
  public
    property text : string read FText write FText;

    function ToJsonString: string;
    class function FromJsonString(const AJsonString: string): TExtendedTextMessage;
  end;

  TMessage = class
  private
    FExtendedTextMessage: TExtendedTextMessage;
  public
    constructor Create;
    destructor Destroy; override;

    property extendedTextMessage : TExtendedTextMessage read FExtendedTextMessage write FExtendedTextMessage;

    function ToJsonString: string;
    class function FromJsonString(const AJsonString: string): TMessage;
  end;

  TKey = class
  private
    FFromMe   : Boolean;
    FId       : string;
    FRemoteJid: string;
  public
    property fromMe    : Boolean read FFromMe    write FFromMe;
    property id        : string  read FId        write FId;
    property remoteJid : string  read FRemoteJid write FRemoteJid;

    function ToJsonString: string;
    class function FromJsonString(const AJsonString: string): TKey;
  end;

  TRespSendText = class
  private
    FKey             : TKey;
    FMessage         : TMessage;
    FMessageTimestamp: string;
    FStatus          : string;
  public
    constructor Create;
    destructor Destroy; override;

    property key              : TKey     read FKey              write FKey;
    property message          : TMessage read FMessage          write FMessage;
    property messageTimestamp : string   read FMessageTimestamp write FMessageTimestamp;
    property status           : string   read FStatus           write FStatus;

    function ToJsonString: string;
    class function FromJsonString(const AJsonString: string): TRespSendText;
  end;

implementation

{TExtendedTextMessage}
function TExtendedTextMessage.ToJsonString: string;
begin
  Result := TJson.ObjectToJsonString(self);
end;

class function TExtendedTextMessage.FromJsonString(const AJsonString: string): TExtendedTextMessage;
begin
  Result := TJson.JsonToObject<TExtendedTextMessage>(AJsonString);
end;

{TMessage}
constructor TMessage.Create;
begin
  inherited;

  FExtendedTextMessage := TExtendedTextMessage.Create;
end;

destructor TMessage.Destroy;
begin
  if Assigned(FExtendedTextMessage) then
    FreeAndNil(FExtendedTextMessage);

  inherited;
end;

function TMessage.ToJsonString: string;
begin
  Result := TJson.ObjectToJsonString(self);
end;

class function TMessage.FromJsonString(const AJsonString: string): TMessage;
begin
  Result := TJson.JsonToObject<TMessage>(AJsonString);
end;

{TKey}
function TKey.ToJsonString: string;
begin
  Result := TJson.ObjectToJsonString(self);
end;

class function TKey.FromJsonString(const AJsonString: string): TKey;
begin
  Result := TJson.JsonToObject<TKey>(AJsonString);
end;

{TRespSendText}
constructor TRespSendText.Create;
begin
  inherited;

  FKey     := TKey.Create;
  FMessage := TMessage.Create;
end;

destructor TRespSendText.Destroy;
begin
  if Assigned(FKey) then
    FreeAndNil(FKey);

  if Assigned(FMessage) then
    FreeAndNil(FMessage);

  inherited;
end;

function TRespSendText.ToJsonString: string;
begin
  Result := TJson.ObjectToJsonString(self);
end;

class function TRespSendText.FromJsonString(const AJsonString: string): TRespSendText;
begin
  Result := TJson.JsonToObject<TRespSendText>(AJsonString);
end;

end.
