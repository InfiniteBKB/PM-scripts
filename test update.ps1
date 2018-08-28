#更新应用程序

#************************begin 参数设置**************************************
#更新版本类型：测试Test、正式Release
$Type = "Test"
#源服务存放更新的文件夹名
$Project_Name = "56CTM"
#目标服务运行文件夹名
$Project_Name_1 = "56CTM_1"
$Project_Name_2 = "56CTM_2"
#目标IIS应用名称
$IIS_Name_1 = "56CTM_1"
$IIS_Name_2 = "56CTM_2"



#（新增20171106）---------------------------
#应用程序池
$AppPools_Path = "IIS:\AppPools\"
$AppPools_Name_1 = $AppPools_Path + $IIS_Name_1
$AppPools_Name_2 = $AppPools_Path + $IIS_Name_2
#-------------------------------------------

#异常处理
Trap {
 #结束执行
 echo "捕获异常信息: $error[0] "
 break
}

$ErrorActionPreference='stop'

#目标服务器数组
$destarray=New-Object 'string[,]' 1,3
#10服务器
$destarray[0,0]="192.168.1.246"
$destarray[0,1]="******"
$destarray[0,2]="******"




#源密码
$originpass = ConvertTo-SecureString -String '******' -AsPlainText -Force 
#凭证
$origincre = New-Object pscredential('Administrator', $originpass)
#源会话
$originsession = New-PSSession -ComputerName 192.168.1.243 -Credential $origincre

#**************************end 参数设置***************************************


#**********************************begin 初始化赋值***************************
#更新当前时间
$today = Get-Date -Format 'yyyyMMddHHmmss'
$File_Name_WithoutEx = $Type + "_" + $Project_Name + "_" + $today
$File_Name = $File_Name_WithoutEx +".zip"

#源环境存放56CTM更新文件目录
$56CTM_Origin_Root = "D:\LogisticsPlatform\"
$56CTM_Origin_Path =$56CTM_Origin_Root + $Project_Name
#源环境存放压缩文件目录
$56CTM_Origin_Send_Path = $56CTM_Origin_Root + "Root_CTM_Send\"
#源拷贝环境发布文件到临时目录
$56CTM_Origin_Send_TEMP_Path = $56CTM_Origin_Send_Path + $File_Name_WithoutEx + "\"
#源测试环境压缩文件
$56CTM_Origin_Send_File_Path = $56CTM_Origin_Send_Path + $File_Name


#目的根目录
$56CTM_Dest_Root = "D:\LogisticsPlatform\"
#目的环境接收测试环境压缩目录
$56CTM_Dest_Receive_Path = $56CTM_Dest_Root + "Root_CTM_Receive\"
#目的环境存放测试环境压缩文件目录
$56CTM_Dest_Receive_File_Path = $56CTM_Dest_Receive_Path + $File_Name
#目的环境存放待发布程序目录
$56CTM_Dest_Update_Path = $56CTM_Dest_Receive_Path + $Project_Name + "\"
#目的运行程序路径
$56CTM_Dest_Path_1 = $56CTM_Dest_Root + $Project_Name_1 
$56CTM_Dest_Path_2 = $56CTM_Dest_Root + $Project_Name_2 

#目标运行程序备份路径
$56CTM_Dest_Backup_Path = $56CTM_Dest_Root + "Root_CTM_Backup\"
#目标运行程序备份路径
#$56CTM_Dest_Backup_File_Path = $56CTM_Dest_Backup_Path + $File_Name
#目标运行程序备份路径
$56CTM_Dest_Backup_File_Path = $56CTM_Dest_Backup_Path + $File_Name_WithoutEx

#发布服务器存放压缩文件路径
$56CTM_Publish_Root = "D:\LogisticsPlatform\"
$56CTM_Publish_Receive_Path = $56CTM_Publish_Root + "Root_CTM_Receive\"
$56CTM_Publish_Send_Path = $56CTM_Publish_Root + "Root_CTM_Send\"
$56CTM_Publish_Receive_File_Path = $56CTM_Publish_Receive_Path + $File_Name
$56CTM_Publish_Send_File_Path = $56CTM_Publish_Send_Path + $File_Name
#**********************************end 目的服务器初始化赋值***************************

echo "测试库发布开始..."

#***********************************begin Origin**************************************
#-ArgumentList传入本地参数
Invoke-Command -Session $originsession -ScriptBlock{
    param($56CTM_Origin_Path,$56CTM_Origin_Send_TEMP_Path,$56CTM_Origin_Send_Path) 
    
    If(Test-Path($56CTM_Origin_Send_Path))
    {}
    Else
    { mkdir $56CTM_Origin_Send_Path }
    
    #创建临时目录
    mkdir $56CTM_Origin_Send_TEMP_Path

    #把Origin环境的运行程序拷贝到临时目录
    cp $56CTM_Origin_Path $56CTM_Origin_Send_TEMP_Path -Recurse -Force
    
} -ArgumentList $56CTM_Origin_Path,$56CTM_Origin_Send_TEMP_Path,$56CTM_Origin_Send_Path


Invoke-Command -Session $originsession -ScriptBlock{
    param($56CTM_Origin_Send_TEMP_Path,$56CTM_Origin_Send_File_Path,$Project_Name)       
  
    $Work_Root = $56CTM_Origin_Send_TEMP_Path + $Project_Name 
    #删除目录DownFile、logs、MakeExcelFiles、upload、Template
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
 
    #删除web.config
    If(Test-Path("$Work_Root\Web.config"))
    { Remove-Item "$Work_Root\Web.config" -Recurse -Force -Confirm:$false  }

    #删除bin目录下NLog.config
    If(Test-Path("$Work_Root\bin\NLog.config"))
    { Remove-Item "$Work_Root\bin\NLog.config" -Recurse -Force -Confirm:$false  }

	#删除主目录下NLog.config
    If(Test-Path("$Work_Root\NLog.config"))
    { Remove-Item "$Work_Root\NLog.config" -Recurse -Force -Confirm:$false  }

    #删除Oracle.DataAccess.dll
    #If(Test-Path("$Work_Root\bin\Oracle.DataAccess.dll"))
    #{ Remove-Item "$Work_Root\bin\Oracle.DataAccess.dll" -Recurse -Force -Confirm:$false  }
    #删除Update_Journal.html
    #If(Test-Path("$Work_Root\Htmls\Update_Journal.html"))
    #{ Remove-Item "$Work_Root\Htmls\Update_Journal.html" -Recurse -Force -Confirm:$false  }
    #删除Sys_Notice.html
    #If(Test-Path("$Work_Root\Htmls\Sys_Notice.html"))
    #{ Remove-Item "$Work_Root\Htmls\Sys_Notice.html" -Recurse -Force -Confirm:$false  }    
   
    #****的56CTM决定了打包后的目录名称**********
    Compress-Archive  -Path $Work_Root  -DestinationPath  $56CTM_Origin_Send_File_Path  -Force
    
    Remove-Item $56CTM_Origin_Send_TEMP_Path -Recurse -Force -Confirm:$false 

} -ArgumentList $56CTM_Origin_Send_TEMP_Path,$56CTM_Origin_Send_File_Path,$Project_Name

#*******************************end Origin*************************************************


#*******************************begin publish服务器****************************************
If(Test-Path($56CTM_Publish_Receive_Path))
{}
Else
{ mkdir $56CTM_Publish_Receive_Path }

If(Test-Path($56CTM_Publish_Send_Path))
{}
Else
{ mkdir $56CTM_Publish_Send_Path }

#把Origin环境压缩的文件拷贝到publish服务器
echo "Origin->publish：from $56CTM_Origin_Send_File_Path to $56CTM_Publish_Receive_File_Path" 
cp -FromSession $originsession -Path $56CTM_Origin_Send_File_Path   -Destination $56CTM_Publish_Receive_File_Path -Recurse -Force

#断开Origin服务器连接
Remove-PSSession -Id $originsession.Id 

#把压缩文件拷贝到发送目录
cp -Path $56CTM_Publish_Receive_File_Path -Destination $56CTM_Publish_Send_File_Path  -Recurse -Force
#*******************************end publish服务器*****************************************


#********************************begin Dest服务器*****************************************
for($i=0;$i -lt $destarray.GetLength(0);$i++)
{
  $private:destserverstring = $destarray[$i,0]
  $private:destuserstring = $destarray[$i,1]
  $private:destpassstring = $destarray[$i,2]
  echo "**************************开始更新 $private:destserverstring *********************************"

  #目标密码
  $private:destpass = ConvertTo-SecureString -String $private:destpassstring -AsPlainText -Force 
  #目标凭证
  $private:destcre = New-Object pscredential($private:destuserstring, $private:destpass)
  #目标会话
  $private:destsession = New-PSSession -ComputerName $private:destserverstring -Credential $private:destcre

  #把publish服务器的压缩文件发送到目标服务器的Receive目录
  echo "publish->Dest：from $56CTM_Publish_Send_File_Path to $56CTM_Dest_Receive_File_Path" 
  cp -Path $56CTM_Publish_Send_File_Path -Destination $56CTM_Dest_Receive_File_Path  -ToSession $destsession -Recurse -Force

  #-ArgumentList传入本地参数********************************
  Invoke-Command -Session $private:destsession -ScriptBlock{
    param($56CTM_Dest_Backup_Path,$56CTM_Dest_Backup_File_Path,$56CTM_Dest_Update_Path,$56CTM_Dest_Path_1,$56CTM_Dest_Path_2,$56CTM_Dest_Receive_File_Path,$56CTM_Dest_Receive_Path,$IIS_Name_1,$IIS_Name_2,$AppPools_Name_1,$AppPools_Name_2) 
 
    #判断backup目录是否存在，如果不存在，创建backup目录
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

    #停止IIS的应用
    echo "测试库IIS：停止 $IIS_Name 服务" 
    Stop-WebSite $IIS_Name_1    
	Stop-WebSite $IIS_Name_2

    #（新增20171106）------------------------------
    #停止IIS的应用程序池
    #echo "正式库IIS：停止 $AppPools_Name 应用程序池"
    #获取应用程序池
    #Stop-WebItem $AppPools_Name  
    #Start-Sleep -s 30
    #----------------------------------------------

    #备份运行程序
    #echo "测试库备份：from $56CTM_Dest_Path_1 to $56CTM_Dest_Backup_File_Path"
    #Compress-Archive  -Path $56CTM_Dest_Path_1  -DestinationPath  $56CTM_Dest_Backup_File_Path  -Force 

    #排除目录
    #$exclude = @('upload','logs','DownFile','logs','MakeExcelFiles')
    #cp "$56CTM_Dest_Path/*" $56CTM_Dest_Backup_File_Path -Recurse -Force -Exclude $exclude
    
    #清除Dest待发布目录
    Remove-Item $56CTM_Dest_Update_Path -Recurse -Force   -Confirm:$false 

    #将压缩文件解压缩
    Expand-Archive $56CTM_Dest_Receive_File_Path -DestinationPath $56CTM_Dest_Receive_Path -Force

    #把待发布的程序拷贝到Dest执行目录
    cp "$56CTM_Dest_Update_Path/*" $56CTM_Dest_Path_1 -Recurse -Force
	cp "$56CTM_Dest_Update_Path/*" $56CTM_Dest_Path_2 -Recurse -Force

    echo "测试库文件已覆盖： $56CTM_Dest_Update_Path ---> $56CTM_Dest_Path " 

    #（新增20171106）------------------------------
    #启动应用程序池
    #echo "测试库IIS：重启 $AppPools_Name 应用程序池" 
    #Start-WebItem $AppPools_Name
    #----------------------------------------------

    #（新增20180524）回收应用程序池----------------     
    $appPool_1 =ls IIS:\apppools |Where-Object{$_.name -eq $IIS_Name_1}
	$appPool_2 =ls IIS:\apppools |Where-Object{$_.name -eq $IIS_Name_2}
    if($appPool){       
       $appPool.recycle()        
       echo "【程序池回收】：回收 $IIS_Name 程序池"
    }
    #----------------------------------------------

    #启动IIS的应用
    echo "正式库IIS：启动 $IIS_Name 服务" 
    Start-WebSite $IIS_Name_1
	Start-WebSite $IIS_Name_2

 } -ArgumentList $56CTM_Dest_Backup_Path,$56CTM_Dest_Backup_File_Path,$56CTM_Dest_Update_Path,$56CTM_Dest_Path_1,$56CTM_Dest_Path_2,$56CTM_Dest_Receive_File_Path,$56CTM_Dest_Receive_Path,$IIS_Name_1,$IIS_Name_2,$AppPools_Name_1,$AppPools_Name_2

    #断开Dest服务器连接
    Remove-PSSession -Id $private:destsession.Id 

    echo "**************************结束更新  $destServerName*********************************"
} 

echo "$Project_Name 【$Type】 更新工作结束"


