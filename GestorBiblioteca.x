typedef char Cadena[150]; /*Definición del tipo de datos Cadena */

struct TLibro      /*Estructura para almacenar los datos de un libro*/
{
   Cadena Isbn;
   Cadena Titulo;
   Cadena Autor;
   int Anio;
   Cadena Pais;
   Cadena Idioma;
   int NoLibros;	/*Número de libros disponibles para prestar.*/
   int NoPrestados;	/*Número de libros prestados.*/
   int NoListaEspera; /*Número de usuarios en lista de espera a recibir un ejemplo del libro.*/
};



/*RPC solo permite un parámetro por servicio, por lo tanto, las siguientes estructuras se utilizarán para el pase de parámetros de algunos servicios. */

struct TFichero    /*Estructura para cargar un fichero de datos. (Servicio CargaDatos) */
{			
   int Ida;        /*Identificador de Administrador.*/
   Cadena NomFile; /*Nombre del fichero a cargar.*/
};

struct TNuevo	    /*Estructura para añadir un libro.  (Servicio NuevoLibro) */ 
{
   int Ida;	    /*Identificador del Administrador.*/
   TLibro Libro;   /*Libro a añadir a la biblioteca.*/
};


struct TComRet	   /*Estructura para comprar o retirar ejemplares de la biblioteca.*/
{						       /*(Servicios Comprar y Retirar)*/
   int Ida;	   /*Identificador del Administrador. */
   Cadena Isbn;   /*Isbn del libro cuyo ejemplares de han comprado o retirado de la biblioteca.*/
   int NoLibros;  /*Número de libros a añadir o a retirar de la biblioteca.*/
};

struct TOrdenacion  /*Estructura para especificar el campo por el cual se va a ordenar los libros. */
{		     								     /*(Servicio Ordenar)*/
   int Ida;       /*Identificador del Administrador. */
   int Campo;     /*Campo por el que se va a ordenar los libros de la biblioteca.*/

};

struct TConsulta  /*Estructura para realizar consultas a la biblioteca. (Servicio Buscar)*/
{
   int Ida;       /*Identificador del Administrador. */
   Cadena Isbn;   /*Isbn a buscar en la biblioteca. */ 
};

struct TPosicion  /*Estructura para buscar un libro en la biblioteca. (Servicios Buscar, Descargar,*/
{ 									   /*Prestar y Devolver )*/
   int Ida;       /*Identificador del Administrador.*/
   int Pos;       /*Posición del libro dentro del vector con el que se va a trabajar.*/
};


program GESTORBIBLIOTECA {
	version GESTORBIBLIOTECA_VER {

    	int Conexion(Cadena pPasswd)=1;

/*Verificará que la contraseña enviada coincida con la del administrador (563498) y devolverá un número  dependiendo de las siguientes condiciones:
	-1: Ya hay un usuario identificado como administrador, solo se permite uno.
	-2: La contraseña es errónea.
	 N: Un número aleatorio generado como 1+rand()%RAND_MAX 
           Este número es el identificador del administrador, se almacena en el servidor (idAdmin) y 
	    se envía al cliente para sea utilizado en las llamadas al servicio. */ 

    	bool Desconexion(int Ida)=2;

/*Desconectará el cliente como administrador. Comprobará que el Ida pasado por parámetro coincide con el almacenado en el servidor. Si no coincide devolverá FALSE y caso contrario borrará el Ida almacenado en el servidor (lo pone a -1)y devolverá TRUE. */

    	int CargarDatos(TFichero pDatos)=3;

/*Abrirá el fichero de datos cuyo nombre es pasado en el campo ‘NomFile’. Verificará que el Ida sea correcto (coincida con el almacenado en el servidor y sea >0), abrirá el fichero binario, creará un vector dinámico de Libros que llenará con el contenido del fichero y finalmente lo cerrará. Una vez cargados los datos en el vector dinámico, los ordenará por el CampoOrdinación que está almacenado en el servidor. Previamente a este proceso se verificará si hay un vector de libros cargados, en cuyo caso se eliminará y creará nuevamente. Las salidas de este servicio serán:
	-1: Ya hay un usuario identificado como administrador o el Ida no coincide con el almacenado en
	    El servidor.
  	 0: No ha se ha podido abrir el fichero o bien ha habido un error de memoria dinámica.
	 1: Se ha cargado correctamente los datos y se han ordenado por el campo almacenado en el 
	    servidor. */


    	bool GuardarDatos(int Ida)=4;

/*Guardará los datos del vector dinámico en el mismo fichero desde el que se cargaron y cuyo nombre está almacenado en el servidor. Previamente se verificará que el Ida sea correcto. La salida de este servicio es TRUE si se ha guardado correctamente los datos o FALSE en caso contrario. */	


	int NuevoLibro(TNuevo pDatos)=5;

/* Añadirá en el vector dinámico el libro pasado en el campo ‘Libro’ y a continuación ordenará el vector dinámico por el CampoOrdenacion almacenado en el servidor. Previamente se verificará que el Ida sea correcto y que ningún libro del vector dinámico contenga el mismo Isbn que el campo ‘Libro’. Las salidas de este servicio serán:
	-1: Ya hay un usuario identificado como administrador o el Ida no coincide con el almacenado en
	     el servidor.
	 0: Hay un libro en el vector dinámico que tiene el mismo Isbn.
	 1: Se ha añadido el nuevo libro al vector dinámico. */


	int Comprar(TComRet pDatos)=6;

/*Añadirá un número de ejemplares (campo NoLibros) al libro del vector dinámico cuyo Isbn coincida con almacenado en el campo ‘Isbn’. Una vez actualizado el número de ejemplares, todos los usuarios en espera de un ejemplar lo recibirán reduciendo consecuentemente la cantidad de libros disponibles. Una vez terminada la compra se ordenará el vector dinámico por el CampoOrdinación almacenado en el servidor. Previamente a todo este proceso se verificará que el Ida sea correcto. Las salidas de este servicio serán:
	-1: Ya hay un usuario identificado como administrador o el Ida no coincide con el almacenado en
           el Servidor.
	 0: No hay un libro en el vector dinámico que tenga el mismo Isbn.
	 1: Se han agregado los nuevos ejemplares del libro y los datos están ordenados. */


 	int Retirar(TComRet pDatos)=7;

/*Retirará un número de ejemplares al libro del vector dinámico cuyo Isbn coincida con indicado en el campo ‘NoLibros’ siempre y cuando haya suficientes libros disponibles parar retirar. Una vez retirados los ejemplare, se ordenará el vector dinámico por el CampoOrdinación almacenado en el Servidor. Previamente a todo este proceso se verificará que el Ida sea correcto y que el libro está en el vector. Las salidas de este servicio serán:
	-1: Ya hay un usuario identificado como administrador o el Ida no coincide con el almacenado en
            el Servidor.
	 0: No hay un libro en el vector dinámico que tiene el mismo Isbn.
	 1: Se han reducido el número de ejemplares disponibles y se han ordenado los datos.
	 2: No hay suficientes ejemplares disponibles para ser retirados. */


	bool Ordenar(TOrdenacion pDatos)=8;

/*Realizará una ordenación de los libros almacenados en el vector dinámico por el campo ‘Campo’. Una vez terminada la ordenación el campo ‘Campo’ será guardado en el servidor para futuras ordenaciones. Previamente a este proceso se verificará que el Ida sea correcto y que el vector dinámico tiene libros Las salidas de este servicio serán:
	FALSE: Ya hay un usuario identificado como administrador o el Ida no coincide con el almacenado
               en el Servidor.
	TRUE: Se ha ordenado correctamente el vector. */
	
 
	int NLibros(int Ida)=9;
 		 
/*Devolverá siempre el número de libros del vector dinámico. No hay que verificar el Ida pasado por parámetro. */


	int Buscar(TConsulta pDatos)=11;

/*Devolverá la posición del Libro cuyo Isbn coincide con el almacenado en el campo ‘Isbn’. Verificará previamente que el Ida es correcto. Las salidas de este servicio serán:
	-2: Ya hay un usuario identificado como administrador o el Ida no coincide con el almacenado en
	    servidor.
	-1: No se ha encontrado ningún libro con el Isbn indicado.
       >=0: La posición del libro dentro de vector dinámico que contiene el mismo Isbn buscado. */

	TLibro Descargar(TPosicion pDatos)=10;

/*Devolverá el libro cuya posición es indicada en el campo ‘Pos’. En el caso que la posición sea incorrecta devolverá un libro con los campos de texto puestos a “????” y los numéricos a 0. Si el Ida no es correcto pondrá a 0 los campos ‘NoPresentados’ y ‘NoListaEspera’ del Libro a devolver. */
	int Prestar(TPosicion pDatos)=12;

/*Prestará a un usuario de la biblioteca un libro cuya posición es indicada en el campo ‘Pos’, de manera que si hay ejemplares disponibles se reducirán en una unidad y los prestados aumentarán en una unidad. Si no hubiera ejemplares disponibles se aumentará el número de usuarios en la lista de espera. Una vez actualizado el se ordenará el vector dinámico por el CampoOrdinación almacenado en el Servidor. Las salidas de este servicio son:
	-1: La posición indicada no está dentro de los límites del vector dinámico.
	 1: Se ha prestado el libro correctamente.
	 0: Se ha puesto el usuario en la lista de espera.  */


	int Devolver(TPosicion pDatos)=13;

/*Devolverá a Gestor Bibliotecario un ejemplar del libro cuya posición es indicada en el campo ‘Pos’, de manera que si hay usuarios en espera se reducirán en una unidad y en caso contrario se reducirá el número de libros prestados y se aumentará el número de libros disponibles. Una vez actualizado los campos del libro, se ordenará el vector dinámico por el CampoOrdinación almacenado en el Servidor. Las salidas de este servicio son:
	-1: La posición indicada no está dentro de los límites del vector dinámico.
	 0: Se ha devuelto el libro reduciendo el número de usuarios en espera.
	 1: Se ha devuelto aumentando el número de libros disponibles.
	 2: El libro no se puede devolver, porque no hay ni usuarios en lista de espera ni libros 
	    prestados.  */

	} = 1;
} = 0x30000001;


