# Development-0001-StringDatetime.sql

El plantamiento del problema es el siguiente:

- Se requiere obtener la fecha publicación de acuerdo a unos formatos de fechas. 


<table style="width: 429px; height: 146px;">
	<tbody>
		<tr style="height: 22px;">
			<td style="height: 22px; width: 163.385px;">&nbsp;DateOfPostText</td>
			<td style="height: 22px; width: 79.4062px;">count_row&nbsp;</td>
			<td style="height: 22px; width: 87.8438px;">&nbsp;lengthString</td>
			<td style="height: 22px; width: 97.6979px;">count_Space&nbsp;</td>
		</tr>
		<tr style="height: 22px;">
			<td style="height: 22px; width: 163.385px;">&nbsp;s&aacute;b a las 12:28</td>
			<td style="height: 22px; width: 79.4062px;">&nbsp;324</td>
			<td style="height: 22px; width: 87.8438px;">&nbsp;15</td>
			<td style="height: 22px; width: 97.6979px;">&nbsp;3</td>
		</tr>
		<tr style="height: 22px;">
			<td style="height: 22px; width: 163.385px;">16 h</td>
			<td style="height: 22px; width: 79.4062px;">&nbsp;301</td>
			<td style="height: 22px; width: 87.8438px;">&nbsp;4</td>
			<td style="height: 22px; width: 97.6979px;">13</td>
		</tr>
		<tr style="height: 21px;">
			<td style="height: 21px; width: 163.385px;">Ayer a las 12:53</td>
			<td style="height: 21px; width: 79.4062px;">982</td>
			<td style="height: 21px; width: 87.8438px;">16</td>
			<td style="height: 21px; width: 97.6979px;">3</td>
		</tr>
		<tr style="height: 27.6667px;">
			<td style="height: 27.6667px; width: 163.385px;">Hace 2 minutos</td>
			<td style="height: 27.6667px; width: 79.4062px;">325</td>
			<td style="height: 27.6667px; width: 87.8438px;">14</td>
			<td style="height: 27.6667px; width: 97.6979px;">3</td>
		</tr>
		<tr style="height: 21px;">
			<td style="height: 21px; width: 163.385px;">Hace 15 horas</td>
			<td style="height: 21px; width: 79.4062px;">232</td>
			<td style="height: 21px; width: 87.8438px;">13</td>
			<td style="height: 21px; width: 97.6979px;">3</td>
		</tr>
	</tbody>
</table>

- La información brindada en la tabla se ha extradido de un maestro que contiene información de una publicación de "X"en la red. Lo que se requieres es convertir ese formato a una fecha visible.
 <pre><code class="hljs language-xml shcb-code-table shcb-line-numbers shcb-wrap-lines">
    SELECT  DateOfPostText, count(1) count_row, len(DateOfPostText) lengthString,len(DateOfPostText) - len(REPLACE(DateOfPostText,' ','')) AS count_Space  
    FROM  [dbo].[Post]
    group by  DateOfPostText </code></pre>
