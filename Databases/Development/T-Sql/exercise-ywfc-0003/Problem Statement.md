 
## Planteamiento del Problema

Caso:
Se requiere hacer busquedas de palabrás claves desde un Frond Web. 

#Requerimiento:
1. Se requiere  2 campos de texto que permitán incluir y filtrar el contenido que necesito.
2. Se requiere 1 campo de texto  que permitirá excluir información no relevante.
3. Los campos deben aceptar tanto palabra clave o frase clase para relizar la busqueda.
4. Tener en consideración que  los campos no siempre tendrán valores que buscar, asi que tendrá que mapear lo escenarios posibles.

#Se detalla los posibles escenarios que los input pueden tener información. 
<table>
<tbody>
<tr>
 <td>Escenarios</td>
<td>Input 1</td>
<td>Input 2</td>
<td>Input 3</td>
</tr>
<tr> Prioridades de Búsqueda  </tr>  
<tr>
<td style="text-align: center;">1</td>
<td style="text-align: center;">X</td>
<td style="text-align: center;">-</td>
<td style="text-align: center;">-</td>
</tr>
  <tr>
<td style="text-align: center;">2</td>
    <td style="text-align: center;">X</td>
<td style="text-align: center;">-</td>
<td style="text-align: center;">X</td>
</tr>
  <tr>
   <td style="text-align: center;">3</td>
<td style="text-align: center;">-</td>
<td style="text-align: center;">X</td>
<td style="text-align: center;">-</td>
</tr>
  <tr>
    <td style="text-align: center;">3</td>
<td style="text-align: center;">-</td>
<td style="text-align: center;">X</td>
<td style="text-align: center;">X</td>
</tr>
  <tr>
    <td style="text-align: center;">4</td>
<td style="text-align: center;">X</td>
<td style="text-align: center;">X</td>
<td style="text-align: center;">-</td>
</tr>
  <tr>
 <td style="text-align: center;">5</td>
<td style="text-align: center;">X</td>
<td style="text-align: center;">X</td>
<td style="text-align: center;">X</td>
</tr>
</tbody>
</table>
# "X" representa que el input tendrá información y se filtrará la información.

