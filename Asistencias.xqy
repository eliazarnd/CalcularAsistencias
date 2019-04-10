
declare namespace functx = "http://www.functx.com";

declare function functx:day-in-year
  ( $date as xs:anyAtomicType? )  as xs:integer? {

  days-from-duration(
      xs:date($date) - functx:first-day-of-year($date)) + 1
 } ;
 
 declare function functx:first-day-of-year
  ( $date as xs:anyAtomicType? )  as xs:date? {

   functx:date(year-from-date(xs:date($date)), 1, 1)
 } ;
 
 declare function functx:date
  ( $year as xs:anyAtomicType ,
    $month as xs:anyAtomicType ,
    $day as xs:anyAtomicType )  as xs:date {

   xs:date(
     concat(
       functx:pad-integer-to-length(xs:integer($year),4),'-',
       functx:pad-integer-to-length(xs:integer($month),2),'-',
       functx:pad-integer-to-length(xs:integer($day),2)))
 } ;
 
 declare function functx:pad-integer-to-length
  ( $integerToPad as xs:anyAtomicType? ,
    $length as xs:integer )  as xs:string {

   if ($length < string-length(string($integerToPad)))
   then error(xs:QName('functx:Integer_Longer_Than_Length'))
   else concat
         (functx:repeat-string(
            '0',$length - string-length(string($integerToPad))),
          string($integerToPad))
 } ;
 
 declare function functx:repeat-string
  ( $stringToRepeat as xs:string? ,
    $count as xs:integer )  as xs:string {

   string-join((for $i in 1 to $count return $stringToRepeat),
                        '')
 } ;

declare function functx:next-day
  ( $date as xs:anyAtomicType? )  as xs:date? {

   xs:date($date) + xs:dayTimeDuration('P1D')
 } ;

(:Funcion para obtener las fechas:)
declare function local:dia-sig($fechaI as xs:anyAtomicType?, $fechaF as xs:anyAtomicType?){
 <Column name = "FECHAS">{$fechaI}</Column>,  
    if(($fechaI) = $fechaF)then()
    else
    ( 
    local:dia-sig(functx:next-day($fechaI),$fechaF)
    )
};
 declare function local:registros 
  ( $usuario as xs:anyAtomicType?, $fecha_Actual as xs:anyAtomicType? ,$tipo as xs:integer) {

for $r in collection("XML/formatosF.xml")//Row
    for $fecha_Actual_U at $i in $horarios_Usuarios/Column[@name = "FECHA_ACTUAL"]               		 
        let $usuarios_Horarios := $horarios_Usuarios[$i]/Column[@name = "CVUSUSARIO"]
        let $horarios_entrada := $horarios_Usuarios[$i]/Column[@name = "HORA_ENTRADA"]
        let $horarios_salida := $horarios_Usuarios[$i]/Column[@name = "HORA_SALIDA"]
        let $usuarios_r := replace($r/Column[@name = "CVEUSUARIO"], '"', '')
        let $fecha_hora := $r/Column[@name = "FECHA_HORA"]
        let $fecha := substring-before($r/Column[@name = "FECHA_HORA"], 'T')
        let $hora_aumento_p := xs:dateTime($horarios_Usuarios[$i]/Column[@name = "HORA_ENTRADA"])+xs:dayTimeDuration('PT10M')
        let $hora_disminucion_p := xs:dateTime($horarios_Usuarios[$i]/Column[@name = "HORA_ENTRADA"])-xs:dayTimeDuration('PT10M')
        let $hora_aumento_ps := xs:dateTime($horarios_Usuarios[$i]/Column[@name = "HORA_SALIDA"])+xs:dayTimeDuration('PT30M')
        let $hora_disminucion_ps := xs:dateTime($horarios_Usuarios[$i]/Column[@name = "HORA_SALIDA"])-xs:dayTimeDuration('PT5M')
        
        (:Agregando incrementos:)
        let $hora_aumento_hora_entrada := xs:dateTime($horarios_Usuarios[$i]/Column[@name = "HORA_ENTRADA"])+xs:dayTimeDuration('PT60M')
        let $hora_disminucion_hora_entrada := xs:dateTime($horarios_Usuarios[$i]/Column[@name = "HORA_ENTRADA"])-xs:dayTimeDuration('PT60M')
        let $hora_aumento_hora_salida := xs:dateTime($horarios_Usuarios[$i]/Column[@name = "HORA_SALIDA"])+xs:dayTimeDuration('PT60M')
        let $hora_disminucion_hora_salida := xs:dateTime($horarios_Usuarios[$i]/Column[@name = "HORA_SALIDA"])-xs:dayTimeDuration('PT60M')
        (:busqueda en todo el dia:)
        let $hora_Todo_dia := concat($fecha_Actual,'T','12:00:00')
            
        where substring-before($fecha_Actual, 'T') = $fecha and number($usuarios_r) = number($usuarios_Horarios) and number($usuarios_Horarios) = number($usuario) and $fecha_Actual = $horarios_entrada
                and
                ((if($tipo = 1)
                    then($fecha_hora >= $hora_disminucion_p and $fecha_hora <= $hora_aumento_p)
                else(
                    ($fecha_hora >= $hora_disminucion_ps and $fecha_hora <= $hora_aumento_ps))   
                )
                or
                (if($tipo = 1)
                    then($fecha_hora <= $hora_aumento_hora_entrada and $fecha_hora >= $hora_disminucion_hora_entrada)
                else(  
                    ($fecha_hora <= $hora_aumento_hora_salida and $fecha_hora >= $hora_disminucion_hora_salida))
                )
                or      
                (if($tipo = 1)
                    then($fecha_hora = $hora_Todo_dia)  
                else(
                    ($fecha_hora = $hora_Todo_dia))     
                ))
                
return 
     (if($tipo = 1)then(    
       if($fecha_hora >= $hora_disminucion_p and $fecha_hora <= $hora_aumento_p )then(
            <f>
                <Column name = "HORA_ENTRADA_REG">{$fecha_hora/text()}</Column>
                <Column name = "ASISTENCIA">'NORMAL'</Column>
            </f>)
       else(    
            <f>
                <Column name = "HORA_ENTRADA_REG">{$fecha_hora/text()}</Column>
                <Column name = "ASISTENCIA">'FALTA'</Column>
            </f>
        )
    )
     else(
         if($tipo != 1)then(
             if($fecha_hora >= $hora_disminucion_ps and $fecha_hora <= $hora_aumento_ps )then(
            <f>
                <Column name = "HORA_SALIDA_REG">{$fecha_hora/text()}</Column>
                <Column name = "ASISTENCIA">'NORMAL'</Column>
            </f>)
        else(    
            <f>
                <Column name = "HORA_SALIDA_REG">{$fecha_hora/text()}</Column>
                <Column name = "ASISTENCIA">'FALTA'</Column>
            </f>
        )
        )     
    )
    )
    
 } ;

declare function functx:day-of-week
  ( $date as xs:anyAtomicType? )  as xs:integer? {

  if (empty($date))
  then ()
  else xs:integer((xs:date($date) - xs:date('1901-01-06'))
          div xs:dayTimeDuration('P1D')) mod 7
 } ;
(:Obtener la vigencia de inicio:)
declare variable $vigencia_I :=
<Vigencia>
{
for $x at $i in collection("XML/horarioF.xml")//Row
    let $vigencia_Inicio :=  $x/Column[@name = "VIGENCIA_INICIO"]
    where $vigencia_Inicio = min(xs:dateTime($vigencia_Inicio)) and $i = 1
return data($vigencia_Inicio)
}
</Vigencia>
;

(:Aqui Comienza:)
declare variable $fecha_Limite :=  xs:date('2016-02-15');
declare variable $fecha_Actual := local:dia-sig(xs:date(substring-before($vigencia_I/text(), 'T'))  , $fecha_Limite);
declare variable $horarios_Vigencias :=
for $x at $i in $fecha_Actual
    for $horarios_Us in collection("XML/horarioF.xml")//Row
        let $cvu :=  number(replace($horarios_Us/Column[@name = "CVEUSUARIO"], '&quot;', ''))
        let $diaSemana :=  $horarios_Us/Column[@name = "DIA_SEMANA"]
        let $horaEntrada := concat($fecha_Actual[$i],'T',substring-after($horarios_Us/Column[@name = "HORA_ENTRADA"], 'T'))
        let $horaSalida :=    concat($fecha_Actual[$i],'T',substring-after($horarios_Us/Column[@name = "HORA_SALIDA"], 'T')) 
        let $vigencia_Final := $horarios_Us/Column[@name = "VIGENCIA_FINAL"]
        
        where $fecha_Actual[$i] >= substring-before($horarios_Us/Column[@name = "VIGENCIA_INICIO"], 'T') and $fecha_Actual[$i] <= 
            substring-before($horarios_Us/Column[@name = "VIGENCIA_FINAL"], 'T') and  functx:day-of-week((xs:date($fecha_Actual[$i])))+1 = number(replace($horarios_Us/Column[@name = "DIA_SEMANA"], '&quot;', ''))
            order by number(replace($x/Column[@name = "CVEUSUARIO"], '&quot;', ''))
return           
    <Table>
        <Column name = "CVEUSUARIO">{data($cvu)}</Column>
        <Column name = "DIA_SEMANA">{data($diaSemana)}</Column>
        <Column name = "HORA_ENTRADA">{data($horaEntrada)}</Column>
        <Column name = "HORA_SALIDA">{data($horaSalida)}</Column>
        <Column name = "VIGENCIA_FINAL">{data($vigencia_Final)}</Column>
        <Column name = "FECHA_ACTUAL">{data($fecha_Actual[$i])}</Column>          
    </Table>;
            
declare variable $horarios_Usuarios := 
for $usuarios at $i in $horarios_Vigencias 
    for $us in collection("XML/usuarios.xml")//Row 
          let $cvuUsu := number(replace($us/Column[@name = "CVUSUARIO"], '&quot;', ''))
          let $nombre := $us/Column[@name = "NOMBRE"]
          let $apellidoPa := $us/Column[@name = "APPATERNO"]
          let $apellidoMa := $us/Column[@name = "APMATERNO"]
          let $nombreC := concat($nombre, " ", $apellidoPa, " ", $apellidoMa)
          let $departamento := $us/Column[@name = "DEPARTAMENTO"]
    where $cvuUsu = number(replace($usuarios/Column[@name = "CVEUSUARIO"], '&quot;', ''))
return 
  <formato>
        <Column name = "NUMERO">{$i}</Column>
        <Column name = "CVUSUSARIO">{data($cvuUsu)}</Column>
        <Column name = "NOMBRE COMPLETO">{data($nombreC)}</Column>
        <Column name = "DEPARTAMENTO">{data($departamento)}</Column>
        {$usuarios/Column}
  </formato>;
        
(:Este es el definitivo:)

declare variable $formato_final := 
for $horarios_Registros at $i in $horarios_Usuarios      
    let $usuarios_Horarios := number(replace($horarios_Registros/Column[@name = "CVUSUSARIO"], '&quot;', ''))
    let $dia_s := number(replace($horarios_Registros/Column[@name = "DIA_SEMANA"], '"', ''))
    let $fecha_horario := $horarios_Registros/Column[@name = "HORA_ENTRADA"]
    let $numero :=  $horarios_Registros/Column[@name = "NUMERO"]
    let $hora_Entrada_Reg := local:registros($usuarios_Horarios,$fecha_horario,1 )/Column[@name = "HORA_ENTRADA_REG"]
    let $hora_Salida_Reg := local:registros($usuarios_Horarios,$fecha_horario,2 )/Column[@name = "HORA_SALIDA_REG"]
    let $asistencia_entrada := local:registros($usuarios_Horarios,$fecha_horario,1 )/Column[@name = "ASISTENCIA"]
    let $asistencia_salida := local:registros($usuarios_Horarios,$fecha_horario,2 )/Column[@name = "ASISTENCIA"]                 
    where $usuarios_Horarios = 76     
return 

  <formato>
        <Column name="NUMERO">{data($numero)}</Column>
        <Column name="CVEUSUARIO">{data($usuarios_Horarios)}</Column>
        <Column name="NOMBRE COMPLETO">{data($horarios_Registros/Column[@name = "NOMBRE COMPLETO"])}</Column>
        <Column name="DEPARTAMENTO">{data($horarios_Registros/Column[@name = "DEPARTAMENTO"])}</Column>
        <Column name="DIA_SEMANA">{data($horarios_Registros/Column[@name = "DIA_SEMANA"])}</Column>
        <Column name="HORA_ENTRADA">{xs:dateTime($horarios_Registros/Column[@name = "HORA_ENTRADA"])}</Column>
         {
        if(empty($hora_Entrada_Reg))
          then(<Column name="HORA_ENTRADA_REG">{'12:00:00'}</Column>)
        else(<Column name="HORA_ENTRADA_REG">{$hora_Entrada_Reg[1]/text()}</Column>)
        }
        <Column name="HORA_SALIDA">{xs:dateTime($horarios_Registros[1]/Column[@name = "HORA_SALIDA"])}</Column>
        {
        if(empty($hora_Salida_Reg))
          then(<Column name="HORA_SALIDA_REG">{'12:00:00'}</Column>)
        else(<Column name="HORA_SALIDA_REG">{$hora_Salida_Reg[1]/text()}</Column>)
        }
        {
          if($asistencia_entrada/text() ="'NORMAL'" and $asistencia_salida/text() = "'NORMAL'")
            then(<Column name = 'ASISTENCIA' >'NORMAL'</Column>)
          else(<Column name = 'ASISTENCIA' >'FALTA'</Column>)
        }      
</formato>;

$formato_final