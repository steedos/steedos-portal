# Steedos Portal App 

Steedos Portal App is an Notification Center for corperate apps, just like Mac. 

### Modal Design

portal_dashboards
{
	space: "",
	name: "Corp Dashboard",
	description: "",
	icon: "ion icon name",
	widgets: ["widget-id"]
}

portal_widgets
{
	space: "",
	name: "Email Inbox Widget",
	title: "Email Inbox",
	description: "show 5 new emails via imap",
	icon: "ion icon name",
	template: "spacebar template",
	cols: 2, // options: 1,2,3,4
	data: [{title: "111", posted: "2012-2-1"}, {title: "222", posted: "2012-1-1"}], // scripts return json data
	onData: "", // javascripts
	onRendered: "" // javascripts
}


### Resourse Url Request Results
1. OA GetMyTask:
测试用户名为eqs-ye，但是用户名前需要额外增加前缀cnpc\\
REQUEST:

Method(GET):
GET /Task%20Portal/Services/ExternalService.asmx/GetMyTask?UserName=cnpc\\eqs-ye&type=1
Host: oa.petrochina

Content-Type: text/xml; charset=utf-8


Method(POST):
POST /Task%20Portal/Services/ExternalService.asmx/GetMyTask
Host: oa.petrochina

Content-Type: application/x-www-form-urlencoded

UserName=cnpc\\eqs-ye&type=1


RESULT:
<?xml version="1.0" encoding="utf-8"?>
<DataSet xmlns="http://tempuri.org/">
    <xs:schema id="NewDataSet" xmlns="" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:msdata="urn:schemas-microsoft-com:xml-msdata">
        <xs:element name="NewDataSet" msdata:IsDataSet="true" msdata:Locale="zh-CN">
            <xs:complexType>
                <xs:choice maxOccurs="unbounded">
                    <xs:element name="Table">
                        <xs:complexType>
                            <xs:sequence>
                                <xs:element name="Title" type="xs:string" minOccurs="0" />
                                <xs:element name="TaskDate" type="xs:dateTime" minOccurs="0" />
                                <xs:element name="URL" type="xs:string" minOccurs="0" />
                                <xs:element name="Level" type="xs:int" minOccurs="0" />
                                <xs:element name="Comment" type="xs:string" minOccurs="0" />
                                <xs:element name="AppName" type="xs:string" minOccurs="0" />
              
                            </xs:sequence>
            
                        </xs:complexType>
          
                    </xs:element>
        
                </xs:choice>
      
            </xs:complexType>
    
        </xs:element>
  
    </xs:schema>
    <diffgr:diffgram xmlns:msdata="urn:schemas-microsoft-com:xml-msdata" xmlns:diffgr="urn:schemas-microsoft-com:xml-diffgram-v1" />

</DataSet>

