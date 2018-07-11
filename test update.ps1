#����Ӧ�ó���

#************************begin ��������**************************************
#���°汾���ͣ�����Test����ʽRelease
$Type = "Test"
#Դ�����Ÿ��µ��ļ�����
$Project_Name = "56CTM"
#Ŀ����������ļ�����
$Project_Name_1 = "56CTM_1"
$Project_Name_2 = "56CTM_2"
#Ŀ��IISӦ������
$IIS_Name_1 = "56CTM_1"
$IIS_Name_2 = "56CTM_2"



#������20171106��---------------------------
#Ӧ�ó����
$AppPools_Path = "IIS:\AppPools\"
$AppPools_Name_1 = $AppPools_Path + $IIS_Name_1
$AppPools_Name_2 = $AppPools_Path + $IIS_Name_2
#-------------------------------------------

#�쳣����
Trap {
 #����ִ��
 echo "�����쳣��Ϣ: $error[0] "
 break
}

$ErrorActionPreference='stop'

#Ŀ�����������
$destarray=New-Object 'string[,]' 1,3
#10������
$destarray[0,0]="192.168.1.246"
$destarray[0,1]="Administrator"
$destarray[0,2]="Dianjue@0702"




#Դ����
$originpass = ConvertTo-SecureString -String 'Dianjue@0702' -AsPlainText -Force 
#ƾ֤
$origincre = New-Object pscredential('Administrator', $originpass)
#Դ�Ự
$originsession = New-PSSession -ComputerName 192.168.1.243 -Credential $origincre

#**************************end ��������***************************************


#**********************************begin ��ʼ����ֵ***************************
#���µ�ǰʱ��
$today = Get-Date -Format 'yyyyMMddHHmmss'
$File_Name_WithoutEx = $Type + "_" + $Project_Name + "_" + $today
$File_Name = $File_Name_WithoutEx +".zip"

#Դ�������56CTM�����ļ�Ŀ¼
$56CTM_Origin_Root = "D:\LogisticsPlatform\"
$56CTM_Origin_Path =$56CTM_Origin_Root + $Project_Name
#Դ�������ѹ���ļ�Ŀ¼
$56CTM_Origin_Send_Path = $56CTM_Origin_Root + "Root_CTM_Send\"
#Դ�������������ļ�����ʱĿ¼
$56CTM_Origin_Send_TEMP_Path = $56CTM_Origin_Send_Path + $File_Name_WithoutEx + "\"
#Դ���Ի���ѹ���ļ�
$56CTM_Origin_Send_File_Path = $56CTM_Origin_Send_Path + $File_Name


#Ŀ�ĸ�Ŀ¼
$56CTM_Dest_Root = "D:\LogisticsPlatform\"
#Ŀ�Ļ������ղ��Ի���ѹ��Ŀ¼
$56CTM_Dest_Receive_Path = $56CTM_Dest_Root + "Root_CTM_Receive\"
#Ŀ�Ļ�����Ų��Ի���ѹ���ļ�Ŀ¼
$56CTM_Dest_Receive_File_Path = $56CTM_Dest_Receive_Path + $File_Name
#Ŀ�Ļ�����Ŵ���������Ŀ¼
$56CTM_Dest_Update_Path = $56CTM_Dest_Receive_Path + $Project_Name + "\"
#Ŀ�����г���·��
$56CTM_Dest_Path_1 = $56CTM_Dest_Root + $Project_Name_1 
$56CTM_Dest_Path_2 = $56CTM_Dest_Root + $Project_Name_2 

#Ŀ�����г��򱸷�·��
$56CTM_Dest_Backup_Path = $56CTM_Dest_Root + "Root_CTM_Backup\"
#Ŀ�����г��򱸷�·��
#$56CTM_Dest_Backup_File_Path = $56CTM_Dest_Backup_Path + $File_Name
#Ŀ�����г��򱸷�·��
$56CTM_Dest_Backup_File_Path = $56CTM_Dest_Backup_Path + $File_Name_WithoutEx

#�������������ѹ���ļ�·��
$56CTM_Publish_Root = "D:\LogisticsPlatform\"
$56CTM_Publish_Receive_Path = $56CTM_Publish_Root + "Root_CTM_Receive\"
$56CTM_Publish_Send_Path = $56CTM_Publish_Root + "Root_CTM_Send\"
$56CTM_Publish_Receive_File_Path = $56CTM_Publish_Receive_Path + $File_Name
$56CTM_Publish_Send_File_Path = $56CTM_Publish_Send_Path + $File_Name
#**********************************end Ŀ�ķ�������ʼ����ֵ***************************

echo "���Կⷢ����ʼ..."

#***********************************begin Origin**************************************
#-ArgumentList���뱾�ز���
Invoke-Command -Session $originsession -ScriptBlock{
    param($56CTM_Origin_Path,$56CTM_Origin_Send_TEMP_Path,$56CTM_Origin_Send_Path) 
    
    If(Test-Path($56CTM_Origin_Send_Path))
    {}
    Else
    { mkdir $56CTM_Origin_Send_Path }
    
    #������ʱĿ¼
    mkdir $56CTM_Origin_Send_TEMP_Path

    #��Origin���������г��򿽱�����ʱĿ¼
    cp $56CTM_Origin_Path $56CTM_Origin_Send_TEMP_Path -Recurse -Force
    
} -ArgumentList $56CTM_Origin_Path,$56CTM_Origin_Send_TEMP_Path,$56CTM_Origin_Send_Path


Invoke-Command -Session $originsession -ScriptBlock{
    param($56CTM_Origin_Send_TEMP_Path,$56CTM_Origin_Send_File_Path,$Project_Name)       
  
    $Work_Root = $56CTM_Origin_Send_TEMP_Path + $Project_Name 
    #ɾ��Ŀ¼DownFile��logs��MakeExcelFiles��upload��Template
    If(Test-Path("$Work_Root\DownFile"))
    { Remove-Item "$Work_Root\DownFile" -Recurse -Force -Confirm:$false }
    If(Test-Path("$Work_Root\logs"))
    { Remove-Item "$Work_Root\logs" -Recurse -Force -Confirm:$false }
    If(Test-Path("$Work_Root\MakeExcelFiles"))
    { Remove-Item "$Work_Root\MakeExcelFiles" -Recurse -Force -Confirm:$false }
    If(Test-Path("$Work_Root\upload"))
    { Remove-Item "$Work_Root\upload" -Recurse -Force -Confirm:$false }
	    If(Test-Path("$Work_Root\Template"))
    { Remove-Item "$Work_Root\Template" -Recurse -Force -Confirm:$false }
 
    #ɾ��web.config
    If(Test-Path("$Work_Root\Web.config"))
    { Remove-Item "$Work_Root\Web.config" -Recurse -Force -Confirm:$false  }

    #ɾ��binĿ¼��NLog.config
    If(Test-Path("$Work_Root\bin\NLog.config"))
    { Remove-Item "$Work_Root\bin\NLog.config" -Recurse -Force -Confirm:$false  }

	#ɾ����Ŀ¼��NLog.config
    If(Test-Path("$Work_Root\NLog.config"))
    { Remove-Item "$Work_Root\NLog.config" -Recurse -Force -Confirm:$false  }

    #ɾ��Oracle.DataAccess.dll
    #If(Test-Path("$Work_Root\bin\Oracle.DataAccess.dll"))
    #{ Remove-Item "$Work_Root\bin\Oracle.DataAccess.dll" -Recurse -Force -Confirm:$false  }
    #ɾ��Update_Journal.html
    #If(Test-Path("$Work_Root\Htmls\Update_Journal.html"))
    #{ Remove-Item "$Work_Root\Htmls\Update_Journal.html" -Recurse -Force -Confirm:$false  }
    #ɾ��Sys_Notice.html
    #If(Test-Path("$Work_Root\Htmls\Sys_Notice.html"))
    #{ Remove-Item "$Work_Root\Htmls\Sys_Notice.html" -Recurse -Force -Confirm:$false  }    
   
    #****��56CTM�����˴�����Ŀ¼����**********
    Compress-Archive  -Path $Work_Root  -DestinationPath  $56CTM_Origin_Send_File_Path  -Force
    
    Remove-Item $56CTM_Origin_Send_TEMP_Path -Recurse -Force -Confirm:$false 

} -ArgumentList $56CTM_Origin_Send_TEMP_Path,$56CTM_Origin_Send_File_Path,$Project_Name

#*******************************end Origin*************************************************


#*******************************begin publish������****************************************
If(Test-Path($56CTM_Publish_Receive_Path))
{}
Else
{ mkdir $56CTM_Publish_Receive_Path }

If(Test-Path($56CTM_Publish_Send_Path))
{}
Else
{ mkdir $56CTM_Publish_Send_Path }

#��Origin����ѹ�����ļ�������publish������
echo "Origin->publish��from $56CTM_Origin_Send_File_Path to $56CTM_Publish_Receive_File_Path" 
cp -FromSession $originsession -Path $56CTM_Origin_Send_File_Path   -Destination $56CTM_Publish_Receive_File_Path -Recurse -Force

#�Ͽ�Origin����������
Remove-PSSession -Id $originsession.Id 

#��ѹ���ļ�����������Ŀ¼
cp -Path $56CTM_Publish_Receive_File_Path -Destination $56CTM_Publish_Send_File_Path  -Recurse -Force
#*******************************end publish������*****************************************


#********************************begin Dest������*****************************************
for($i=0;$i -lt $destarray.GetLength(0);$i++)
{
  $private:destserverstring = $destarray[$i,0]
  $private:destuserstring = $destarray[$i,1]
  $private:destpassstring = $destarray[$i,2]
  echo "**************************��ʼ���� $private:destserverstring *********************************"

  #Ŀ������
  $private:destpass = ConvertTo-SecureString -String $private:destpassstring -AsPlainText -Force 
  #Ŀ��ƾ֤
  $private:destcre = New-Object pscredential($private:destuserstring, $private:destpass)
  #Ŀ��Ự
  $private:destsession = New-PSSession -ComputerName $private:destserverstring -Credential $private:destcre

  #��publish��������ѹ���ļ����͵�Ŀ���������ReceiveĿ¼
  echo "publish->Dest��from $56CTM_Publish_Send_File_Path to $56CTM_Dest_Receive_File_Path" 
  cp -Path $56CTM_Publish_Send_File_Path -Destination $56CTM_Dest_Receive_File_Path  -ToSession $destsession -Recurse -Force

  #-ArgumentList���뱾�ز���********************************
  Invoke-Command -Session $private:destsession -ScriptBlock{
    param($56CTM_Dest_Backup_Path,$56CTM_Dest_Backup_File_Path,$56CTM_Dest_Update_Path,$56CTM_Dest_Path_1,$56CTM_Dest_Path_2,$56CTM_Dest_Receive_File_Path,$56CTM_Dest_Receive_Path,$IIS_Name_1,$IIS_Name_2,$AppPools_Name_1,$AppPools_Name_2) 
 
    #�ж�backupĿ¼�Ƿ���ڣ���������ڣ�����backupĿ¼
    #If(Test-Path($56CTM_Dest_Backup_Path))
    #{}
    #Else
    #{ mkdir $56CTM_Dest_Backup_Path }

    #If(Test-Path($56CTM_Dest_Update_Path))
    #{}
    #Else
    #{ mkdir $56CTM_Dest_Update_Path }

    #If(Test-Path($56CTM_Dest_Backup_File_Path))
    #{}
    #Else
    #{ mkdir $56CTM_Dest_Backup_File_Path }

    #If(Test-Path($56CTM_Dest_Path_1))
    #{}
    #Else
    #{ mkdir $56CTM_Dest_Path_1 }
	#If(Test-Path($56CTM_Dest_Path_2))
    #{}
    #Else
    #{ mkdir $56CTM_Dest_Path_2 }

    #ֹͣIIS��Ӧ��
    echo "���Կ�IIS��ֹͣ $IIS_Name ����" 
    Stop-WebSite $IIS_Name_1    
	Stop-WebSite $IIS_Name_2

    #������20171106��------------------------------
    #ֹͣIIS��Ӧ�ó����
    #echo "��ʽ��IIS��ֹͣ $AppPools_Name Ӧ�ó����"
    #��ȡӦ�ó����
    #Stop-WebItem $AppPools_Name  
    #Start-Sleep -s 30
    #----------------------------------------------

    #�������г���
    #echo "���Կⱸ�ݣ�from $56CTM_Dest_Path_1 to $56CTM_Dest_Backup_File_Path"
    #Compress-Archive  -Path $56CTM_Dest_Path_1  -DestinationPath  $56CTM_Dest_Backup_File_Path  -Force 

    #�ų�Ŀ¼
    #$exclude = @('upload','logs','DownFile','logs','MakeExcelFiles')
    #cp "$56CTM_Dest_Path/*" $56CTM_Dest_Backup_File_Path -Recurse -Force -Exclude $exclude
    
    #���Dest������Ŀ¼
    Remove-Item $56CTM_Dest_Update_Path -Recurse -Force   -Confirm:$false 

    #��ѹ���ļ���ѹ��
    Expand-Archive $56CTM_Dest_Receive_File_Path -DestinationPath $56CTM_Dest_Receive_Path -Force

    #�Ѵ������ĳ��򿽱���Destִ��Ŀ¼
    cp "$56CTM_Dest_Update_Path/*" $56CTM_Dest_Path_1 -Recurse -Force
	cp "$56CTM_Dest_Update_Path/*" $56CTM_Dest_Path_2 -Recurse -Force

    echo "���Կ��ļ��Ѹ��ǣ� $56CTM_Dest_Update_Path ---> $56CTM_Dest_Path " 

    #������20171106��------------------------------
    #����Ӧ�ó����
    #echo "���Կ�IIS������ $AppPools_Name Ӧ�ó����" 
    #Start-WebItem $AppPools_Name
    #----------------------------------------------

    #������20180524������Ӧ�ó����----------------     
    $appPool_1 =ls IIS:\apppools |Where-Object{$_.name -eq $IIS_Name_1}
	$appPool_2 =ls IIS:\apppools |Where-Object{$_.name -eq $IIS_Name_2}
    if($appPool){       
       $appPool.recycle()        
       echo "������ػ��ա������� $IIS_Name �����"
    }
    #----------------------------------------------

    #����IIS��Ӧ��
    echo "��ʽ��IIS������ $IIS_Name ����" 
    Start-WebSite $IIS_Name_1
	Start-WebSite $IIS_Name_2

 } -ArgumentList $56CTM_Dest_Backup_Path,$56CTM_Dest_Backup_File_Path,$56CTM_Dest_Update_Path,$56CTM_Dest_Path_1,$56CTM_Dest_Path_2,$56CTM_Dest_Receive_File_Path,$56CTM_Dest_Receive_Path,$IIS_Name_1,$IIS_Name_2,$AppPools_Name_1,$AppPools_Name_2

    #�Ͽ�Dest����������
    Remove-PSSession -Id $private:destsession.Id 

    echo "**************************��������  $destServerName*********************************"
} 

echo "$Project_Name ��$Type�� ���¹�������"


