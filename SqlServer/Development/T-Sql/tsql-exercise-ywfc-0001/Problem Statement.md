La configuración de por defecto de las tareas de Backups es que se realicen los Backups diariamente, y generen un Backup en la carpeta designada a los Backups. También debe de realizarse una verificación de estos backups a fin de encontrar errores que puedan darse en el proceso de Backup.

Asimismo, este Backups debe de reemplazarse cada día a fin de no saturar el disco designado del servidor. Posteriormente se debe de definir otra tarea que copie los Backups de las bases de datos a otro servidor a modo de contingencia.

Para crear las tareas de backups, primero se deben de crear los backup Devices por cada una de las bases de datos. Para realizar esta acción, debemos de ejecutar el siguiente script:
