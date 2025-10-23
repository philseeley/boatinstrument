A default install of SignalK does not need authentication to read data. Therefore if you are only using the app to display data no further action is required. 

If authentic is required, the app uses authentication tokens. These can be set on the main connection and additional tokens are required to enable certain functions, e.g. autopilot control and setting the anchor alarm.

If your SignalK server has been configured to require authentication for all access, then you will require at least a read-only token set in the main settings. 

For functions like the autopilot, the tokens are set within the box settings. 

## Setting Authentic Tokens

Setting an authentication token is a two step process. First you make an access request using the ![request](assets/icons/__THEME__/login.png) button. The **Auth Token** will show **PENDING**. Second, without closing the app settings page, you authorise the request from the SignalK web interface by going to the **Security->Access Requests** page. Unless you have modified the default SignalK security settings, you only have to select the access level required and press **Approve**. Back in the app, wait for the authentication token to be displayed before closing the settings page.

## Remote Control

To enable Remote Control of the app, both the **Controlling** and **Controlled** apps must have a read/write **Auth Token** set in the main Settings page. The Controlled app must also enable the **Allow Remote Control** setting. 

See [Remote Control](doc:remote-control.md) for more details.