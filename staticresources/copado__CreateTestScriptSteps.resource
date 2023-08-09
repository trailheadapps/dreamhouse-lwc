var ctss = {
	ns: 'copado__',

	recalculateOrder: function (){
		var x = 0;
		var steps = [];
		
		$copado("#tbl_TestScriptSteps").find("tbody>tr").each(function() {
			arrayInt = x;
			x++;
				$this = $copado(this);
				var i = $this.find("input[name='hiddenStepId']").val();
				var o = $this.find("input[name='hiddenStepOrder']").val();
				var s = new sforce.SObject(ctss.ns+"Test_Script_Step__c");
				s.Id = i;
				s[ctss.ns+'Order__c'] = x;
				steps[arrayInt] = s;
		});
		var result = sforce.connection.update(steps);
	}
}

	