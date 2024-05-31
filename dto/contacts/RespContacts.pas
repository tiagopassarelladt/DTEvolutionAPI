unit RespContacts;

interface
  uses
    System.SysUtils,
    Generics.Collections,
    REST.Json.Types,
    Rest.Json;

type

  TLista = class
  private
    FId               : string;
    FOwner            : string;
    FProfilePictureUrl: string;
    FPushName         : string;
  public
    property id                : string read FId                write FId;
    property owner             : string read FOwner             write FOwner;
    property profilePictureUrl : string read FProfilePictureUrl write FProfilePictureUrl;
    property pushName          : string read FPushName          write FPushName;

    function ToJsonString: string;
    class function FromJsonString(const AJsonString: string): TLista;
  end;

  TResult = class
  private
    FLista: TArray<TLista>;
  public
    destructor Destroy; override;

    property lista : TArray<TLista> read FLista write FLista;

    function ToJsonString: string;
    class function FromJsonString(const AJsonString: string): TResult;
  end;

  TRespContacts = class
  private
    FResult: TResult;
  public
    constructor Create;
    destructor Destroy; override;

    property result : TResult read FResult write FResult;

    function ToJsonString: string;
    class function FromJsonString(const AJsonString: string): TRespContacts;
  end;

implementation

{TLista}
function TLista.ToJsonString: string;
begin
  Result := TJson.ObjectToJsonString(self);
end;

class function TLista.FromJsonString(const AJsonString: string): TLista;
begin
  Result := TJson.JsonToObject<TLista>(AJsonString);
end;

{TResult}

destructor TResult.Destroy;
var
  LlistaItem: TLista;
begin

 for LlistaItem in FLista do
   LlistaItem.free;

  inherited;
end;

function TResult.ToJsonString: string;
begin
  Result := TJson.ObjectToJsonString(self);
end;

class function TResult.FromJsonString(const AJsonString: string): TResult;
begin
  Result := TJson.JsonToObject<TResult>(AJsonString);
end;

{TResp}
constructor TRespContacts.Create;
begin
  inherited;

  FResult := TResult.Create;
end;

destructor TRespContacts.Destroy;
begin
  if Assigned(FResult) then
    FreeAndNil(FResult);

  inherited;
end;

function TRespContacts.ToJsonString: string;
begin
  Result := TJson.ObjectToJsonString(self);
end;

class function TRespContacts.FromJsonString(const AJsonString: string): TRespContacts;
begin
  Result := TJson.JsonToObject<TRespContacts>(AJsonString);
end;

end.

