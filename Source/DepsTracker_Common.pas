unit DepsTracker_Common;

{$INCLUDE '.\DepsTracker_defs.inc'}

interface

uses
  AuxExceptions;

{===============================================================================
    Project-specific exceptions
===============================================================================}
type
  EDTException = class(EGeneralException);

  EDTIndexOutOfBounds = class(EDTException);
  EDTInvalidValue     = class(EDTException);
  EDTDuplicateError   = class(EDTException);
  EDTInvalidFile      = class(EDTException);

{===============================================================================
    Common types and constants
===============================================================================}
type
  TDTProjectType = (ptOthers,ptLibrary,ptBinding,ptFramework,ptProgram,ptDynLibrary);

const
  DT_PROJTYPE_STRS: array[TDTProjectType] of String =
    ('Others','Library','Binding','Framework','Program','Dynamic library');

  DT_PROJTYPE_TAGS: array[TDTProjectType] of String =
    ('   ','lib','bnd','frm','prg','dll');

Function ProjectTypeToNum(ProjectType: TDTProjectType): Byte;
Function NumToProjectType(Value: Byte): TDTProjectType;

type
  TDTObjectArray = array of TObject;
  
implementation

const
  DT_PROJTYPE_OTH = 0;
  DT_PROJTYPE_LIB = 1;
  DT_PROJTYPE_BND = 2;
  DT_PROJTYPE_FRM = 3;
  DT_PROJTYPE_PRG = 4;
  DT_PROJTYPE_DLL = 5;

//------------------------------------------------------------------------------  

Function ProjectTypeToNum(ProjectType: TDTProjectType): Byte;
begin
case ProjectType of
  ptLibrary:    Result := DT_PROJTYPE_LIB;
  ptBinding:    Result := DT_PROJTYPE_BND;
  ptFramework:  Result := DT_PROJTYPE_FRM;
  ptProgram:    Result := DT_PROJTYPE_PRG;
  ptDynLibrary: Result := DT_PROJTYPE_DLL;
else
 {ptOthers}
  Result := DT_PROJTYPE_OTH;
end;
end;

//------------------------------------------------------------------------------

Function NumToProjectType(Value: Byte): TDTProjectType;
begin
case Value of
  DT_PROJTYPE_LIB:  Result := ptLibrary;
  DT_PROJTYPE_BND:  Result := ptBinding;
  DT_PROJTYPE_FRM:  Result := ptFramework;
  DT_PROJTYPE_PRG:  Result := ptProgram;
  DT_PROJTYPE_DLL:  Result := ptDynLibrary;
else
 {DT_PROJTYPE_OTH}
  Result := ptOthers;
end;
end;

end.
