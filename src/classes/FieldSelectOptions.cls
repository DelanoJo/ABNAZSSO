public with sharing class FieldSelectOptions {
    private String objectName;
    private List<SelectOption> options = new List<SelectOption>();
    
    public FieldSelectOptions(String objectName) {
        this.objectName = objectName;
        System.debug('this.objectName = '+this.objectName);
        Schema.SObjectType ot = Schema.getGlobalDescribe().get(objectName);
        System.assert(ot != null, 'Unknown object name "' + objectName + '" in schema ' + Schema.getGlobalDescribe());
        init(ot);
    }
    
    public FieldSelectOptions(Schema.SObjectType ot) {
        init(ot);
    }
    
    private void init(Schema.SObjectType ot) {
        Map<String,Schema.SObjectField> fields = ot.getDescribe().fields.getMap();
        options.clear();
        List<String> fieldNames = new List<String>(fields.keySet());
        fieldNames.sort();
        for (String fn : fieldNames) {
            Schema.DescribeFieldResult f = fields.get(fn).getDescribe() ;
            if(( f.isAccessible() ) && (f.isFilterable()) && f.getType() != Schema.DisplayType.DATETIME) {  // && f.getType() == DisplayType.String
                options.add(new SelectOption(fn, f.getLabel()));
                //this.sort(options);
            }
        }
    }
/*  
    private void sort(List<SelectOption> l){
        boolean isSorted = false;
        if (!(l == null)&&(l.size() > 1)) {
            while (!isSorted){
            isSorted = true;    
            for(integer i = 0; i < (l.size()-1); i++ ){
                if (l[i].getlabel() > l[i+1].getlabel()){
                    isSorted = false;
                    Selectoption s = l[i];
                    l[i] = l[i+1];
                    l[i+1] = s;
                }
            }
            }
            
        }           
    }
*/          
    public List<SelectOption> getOptions() {
        return options;
    }
}