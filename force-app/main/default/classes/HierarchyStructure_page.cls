/*
    @ Test File     : HierarchyStructure_pageTest
    @ Last Modified By  : Petr Svestka 
    @ Last Modified On  : Aug 11, 2015
    @ Modification Description : Force.com reviewer - Blocker and Critical issues - 20150608.xlsx
*/
public with sharing class HierarchyStructure_page extends ComponentControllerBase{

    //Declare variables
    public String currentId{get;set;}
    public String objectName{get;set;}
    public String hierarchyField{get;set;}
    public String hierarchyClassifyField{get;set;}
    public List<ObjectStructureMap> asm ;
    public Map<String, ObjectStructureMap> masm;
    public List<Integer> maxLevel;
    private Map<ID, String> theIdNodeList;
    private Map<String,ID> theNodeIdList;
    public String parentId{get;set;}
    public List<Id> theChildren{get;set;}

    private Map<ID, String> nodeList = new Map<ID, String>();
    private List<myNode> myNodeSortList = new List<myNode>{};
    
    /**
    * Constructor
    */
    public HierarchyStructure_page() {
        this.asm = new List<ObjectStructureMap>{};
        this.masm = new Map<String, ObjectStructureMap>{};
        this.maxLevel = new List<Integer>{};
        this.theIdNodeList = new Map<ID, String>{};
        this.theNodeIdList = new Map<String, ID>{};
    }
    public List<Id> getHierarchyChildren(String parentId){
        return getChildrenByRecordId(parentId);
    }

    public void fetchChildren(){
        theChildren = getChildrenByNodeId(parentId);
    }

    public void fetchChildren(String parentId){
        theChildren = getChildrenByRecordId(parentId);
    }
    
    /**
    * Return ObjectStructureMap to page
    * @return asm
    */
    public List<ObjectStructureMap> getObjectStructure(){
        asm.clear();

        if ( currentId == null ) {
            return asm;
        }

        System.assertNotEquals( currentId, null, 'sObject ID must be provided' );
        asm = formatObjectStructure( currentId );

        return asm;

    }

    @TestVisible
    private Integer recrs(List<ID> currentParent, Integer level) {
        List<sObject> ol = new List<sObject>();
        String nodeId = '0';

        String topLevelQueryString = 'SELECT OwnerId, Name, Id, '+ this.hierarchyField;
        if (hierarchyClassifyField != null) {topLevelQueryString += ', '+this.hierarchyClassifyField;}
        topLevelQueryString += ' FROM ' +this.objectName +' WHERE id IN : CurrentParent ORDER BY Name limit 500'; // CR: TODO Check data for Client Hierarchy in excess of 500 records. SF displays account hierarchy for first 500 records only by default.

        String childQueryString = 'SELECT OwnerId, Name, Id, '+ this.hierarchyField;
        if (hierarchyClassifyField != null) {childQueryString += ', '+this.hierarchyClassifyField;}
        childQueryString += ' FROM ' +this.objectName +' WHERE ' +this.hierarchyField +' IN : CurrentParent ORDER BY Name limit 500';

        if (level == 0) {
            ol = Database.query(topLevelQueryString);
        } else {
            ol = Database.query(childQueryString);
        }

        if (ol == null || ol.size() == 0) {
            return 0;
        } else {
            currentParent.clear();

            for (Integer i = 0; i < ol.size(); i++) {
                sObject o = ol[i];
                String nodeIdString = i.format();

                if (nodeIdString.length() == 3) nodeIdString = '0' + nodeIdString;
                if (nodeIdString.length() == 2) nodeIdString = '00' + nodeIdString;
                if (nodeIdString.length() == 1) nodeIdString = '000' + nodeIdString;

                nodeId = (level > 0) ? nodeList.get((Id) o.get(this.hierarchyField)) + '.' + nodeIdString : nodeIdString ;
                masm.put(nodeID, new ObjectStructureMap(nodeID, new List<Boolean>(), new List<Boolean>(), 'child', false, false, o, (this.hierarchyClassifyField != null) ? (String)o.get(this.hierarchyClassifyField) : null));
                currentParent.add((Id) o.get('id'));
                nodeList.put((Id) o.get('id'), nodeId);

                theIdNodeList.put((Id) o.get('id'), nodeId);
                theNodeIdList.put(nodeId, (Id) o.get('id'));

                MyNode newNode = new myNode(nodeId);
                myNodeSortList.add(newNode);
            }

            maxLevel.add(level);
            level++;

            return recrs(currentParent, level);
        }
    }

    /**
    * Query sObject from top down to build the ObjectStructureMap
    * @param currentId
    * @return asm
    */
    public ObjectStructureMap[] formatObjectStructure( String curId ){
        List<ObjectStructureMap> asm = new List<ObjectStructureMap>{};
        masm.clear();
        theIdNodeList.clear();
        theNodeIdList.clear();

        List<ID> currentParent      = new List<ID>{};

        //Find highest level object in the structure
        currentParent.add( getTopElement( curId ) );

        recrs(currentParent, 0);

        //Object structure must now be formatted
        myNodeSortList.sort();
        for( Integer i = 0; i < myNodeSortList.size(); i++ ){
            List<String> pnl = new List<String> {};
            List<String> cnl = new List<String> {};
            List<String> nnl = new List<String> {};

            if ( i > 0 ){
                String pn   = myNodeSortList[i-1].nodeId;
                pnl     = pn.split( '\\.', -1 );
            }

            String cn   = myNodeSortList[i].nodeId;
            cnl     = cn.split( '\\.', -1 );

            if( i < myNodeSortList.size()-1 ){
                String nn = myNodeSortList[i+1].nodeId;
                nnl = nn.split( '\\.', -1 );
            }

            ObjectStructureMap tasm = masm.get( cn );
            if ( cnl.size() < nnl.size() ){
                //Parent
                tasm.nodeType = ( isLastNode( cnl ) ) ? 'parent_end' : 'parent';
            }
            else if( cnl.size() > nnl.size() ){
                tasm.nodeType   = 'child_end';
                tasm.closeFlag   = setcloseFlag( cnl, nnl, tasm.nodeType );
            }
            else{
                tasm.nodeType = 'child';
            }

            tasm.levelFlag = setlevelFlag( cnl, tasm.nodeType );

            if ( (Id)tasm.theObject.get('id') == curId  ) {
                tasm.currentNode = true;
            }
            asm.add( tasm );
        }

        asm[0].nodeType       = 'start';
        asm[asm.size()-1].nodeType   = 'end';

        return asm;
    }


    public List<Id> getChildrenByRecordId (String parentRecordId){
        List<Id> theChildren = new List<Id>();
        theChildren.clear();
        String parentNodeId = theIdNodeList.get(parentRecordId);
        for( String theNodeId : theIdNodeList.Values()){
            if (theNodeId.startsWith(parentNodeId)) {
                theChildren.add(theNodeIdList.get(theNodeId));
            }
        }
        return theChildren;
    }

    public List<Id> getChildrenByNodeId (String parentNodeId){
        List<Id> theChildren = new List<Id>();
        theChildren.clear();
        for( String theNodeId : theIdNodeList.Values()){
            if (theNodeId.startsWith(parentNodeId)) {
                theChildren.add(theNodeIdList.get(theNodeId));
            }
        }
        return theChildren;
    }
    
    /**
    * Determin parent elements relationship to current element
    * @return flagList
    */
    public List<Boolean> setlevelFlag( List<String> nodeElements, String nodeType ){

        List<Boolean> flagList = new List<Boolean>{};
        String searchNode   = '';
        String workNode   = '';
        Integer cn       = 0;

        for( Integer i = 0; i < nodeElements.size() - 1; i++ ){
            cn = Integer.valueOf( nodeElements[i] );
            cn++;
            searchNode   = workNode + String.valueOf( cn );
            workNode   = workNode + nodeElements[i] + '.';
            if ( masm.containsKey( searchNode ) ){
                flagList.add( true );
            }
            else {
                flagList.add( false );
            }
        }

        return flagList;
    }
    
    /**
    * Determin if the element is a closing element
    * @return flagList
    */
    public List<Boolean> setcloseFlag( List<String> cnl, List<String> nnl, String nodeType ){

        List<Boolean> flagList = new List<Boolean>{};

        for( Integer i = nnl.size(); i < cnl.size(); i++ ){
            flagList.add( true );
        }

        return flagList;
    }
    
    /**
    * Determin if Element is the bottom node  
    * @return Boolean
    */
    public Boolean isLastNode( List<String> nodeElements ){

        String searchNode   = '';
        Integer cn       = 0;

        for( Integer i = 0; i < nodeElements.size(); i++ ){
            if ( i == nodeElements.size()-1 ){
                cn = Integer.valueOf( nodeElements[i] );
                cn++;
                searchNode = searchNode + String.valueOf( cn );
            }
            else {
                searchNode = searchNode + nodeElements[i] + '.';
            }
        }
        if ( masm.containsKey( searchNode ) ){
            return false;
        }
        else{
            return true;
        }
    }
    
    /**
    * Find the top most element in Hierarchy  
    * @return objId
    */
    public String getTopElement(String objId) {
        sObject o = Database.query('Select Id, '+this.hierarchyField+' From '+ this.ObjectName + ' where id = : objId limit 1');
        return (o.get(this.hierarchyField) != null) ? getTopElement((Id)o.get(this.hierarchyField)) : objId;
    }
    
    /**
      * Node Wrapperclass
      */
    public with sharing class myNode implements Comparable{
        public String nodeId{get;set;}
        public String nodeParentId{get;set;}
        Public myNode(String nodeId){
            this.nodeId = nodeId;
            List<String> nnl = this.nodeId.split( '\\.', -1 );
            if (nnl.size() > 1) this.nodeParentId = nnl[nnl.size()-2];
        }
        public Integer compareTo(Object compareTo) {
            myNode compareTomyNode  = (myNode)compareTo;
            if (this.nodeId == compareTomyNode.nodeId) return 0;
            List<String> nnl = this.nodeId.split( '\\.', -1 );
            List<String> cnl = compareTomyNode.nodeId.split( '\\.', -1 );
            Integer thisNodeSize = nnl.size();
            Integer compareToNodeSize = cnl.size();
            if (thisNodeSize>compareToNodeSize){
                if (thisNodeSize-compareToNodeSize==1){
                    system.debug('comparing: '+nnl[thisNodeSize-2]+' with: '+cnl[compareToNodeSize-1]);
                    if (integer.valueOf(nnl[thisNodeSize-2]) == integer.valueOf(cnl[compareToNodeSize-1])){
                        return -1;
                    }
                    return 1;
                }
            } else if (thisNodeSize==compareToNodeSize && (thisNodeSize>1)){
                if( (integer.valueOf(nnl[thisNodeSize-2]) == integer.valueOf(cnl[compareToNodeSize-2])) && (integer.valueOf(nnl[thisNodeSize-1]) > integer.valueOf(cnl[compareToNodeSize-1]))){
                    return 1;
                }
                if( (integer.valueOf(nnl[thisNodeSize-2]) == integer.valueOf(cnl[compareToNodeSize-2])) && (integer.valueOf(nnl[thisNodeSize-1]) == integer.valueOf(cnl[compareToNodeSize-1]))){
                    return 0;
                }
                return -1;
            } else {
                if( (integer.valueOf(nnl[thisNodeSize-1]) > integer.valueOf(cnl[compareToNodeSize-2]))){
                    return 1;
                }
            }
            return -1;
        }
    }
    
  /**
    * Wrapper class
    */
    public with sharing class ObjectStructureMap{

        public String nodeId;
        public Boolean[] levelFlag = new Boolean[]{};
        public Boolean[] closeFlag = new Boolean[]{};
        public String nodeType;
        public Boolean currentNode;
        public String nodeIcon;
        public sObject theObject;
        public String getnodeId() { return nodeId; }
        public Boolean[] getlevelFlag() { return levelFlag; }
        public Boolean[] getcloseFlag() { return closeFlag; }
        public String getnodeType() { return nodeType; }
        public Boolean getcurrentNode() { return currentNode; }
        public String getnodeIcon() {return nodeIcon;}
        public sObject getObject() { return theObject; }

        public void setnodeId( String n ) { this.nodeId = n; }
        public void setlevelFlag( Boolean l ) { this.levelFlag.add(l); }
        public void setlcloseFlag( Boolean l ) { this.closeFlag.add(l); }
        public void setnodeType( String nt ) { this.nodeType = nt; }
        public void setcurrentNode( Boolean cn ) { this.currentNode = cn; }
        public void setnodeIcon( String ni ) { this.nodeIcon = ni; }
        public void setObject( sObject o ) { this.theObject = o; }


        public ObjectStructureMap( String nodeId, Boolean[] levelFlag,Boolean[] closeFlag , String nodeType, Boolean lastNode, Boolean currentNode, sObject o, String itemType ){

            this.nodeId         = nodeId;
            this.levelFlag      = levelFlag;
            this.closeFlag      = closeFlag;
            this.nodeType       = nodeType;
            this.currentNode    = currentNode;

            this.theObject = o;
            this.nodeIcon = '/img/icon/';
            if (null != itemType) {
                if (itemType == 'Prospect'){ this.nodeIcon += 'lookup32.png';
                } else if (itemType == 'IB Client' ) { this.nodeIcon += 'custom51_100/compass32.png';
                } else if (itemType == 'PBB Client' ) { this.nodeIcon += 'bank32.png';
                } else if (itemType == 'CRT Child' ) { this.nodeIcon += 'hands32.png';
                } else if (itemType == 'CRT Top Parent' ) { this.nodeIcon += 'building32.png';
                } else if (itemType == 'Non CRT Account' ) { this.nodeIcon += 'diamond32.png';
                } else { this.nodeIcon += 'custom51_100/buildingBlock32.png';}
            } else {
                if (nodeType == 'start') {this.nodeIcon += 'building32.png';
                } else if (nodeType=='parent'){this.nodeIcon += 'bank32.png';
                } else if (nodeType=='child') {this.nodeIcon += 'hands32.png';
                } else if (nodeType=='end'){this.nodeIcon += 'diamond32.png';
                }
            }
        }
    }
}