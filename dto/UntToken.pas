unit UntToken;

interface

Type TToken = class
    public
    function GenerateToken: string;
end;

implementation

function TToken.GenerateToken: string;
var
  i: Integer;
begin
  Randomize;
  Result := '';
  for i := 1 to 12 do
  begin
    if Random(2) = 0 then
      Result := Result + Chr(Ord('A') + Random(26))
    else
      Result := Result + Chr(Ord('a') + Random(26));
  end;
end;

end.
