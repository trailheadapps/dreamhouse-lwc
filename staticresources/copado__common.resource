function checkAll(cb,table,cbid){
	var tbody = document.getElementById([id=table]);
	var es = tbody.getElementsByTagName("input");                     
	for(var i=0; i<es.length; i++){             
        	if(es[i].id.indexOf(cbid)!=-1){                                        
                    es[i].checked = cb.checked;
                }
	}
}	