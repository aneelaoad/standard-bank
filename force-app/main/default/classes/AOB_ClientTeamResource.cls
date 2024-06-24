/**
 * Created by Caro on 2019-02-01.
 */

@RestResource(urlMapping='/ClientTeam/*')
global class AOB_ClientTeamResource {

    @HttpGet
    global static ClientTeam doGet() {

        String cifNumber = RestContext.request.params.get('cif');
        String clientRole = RestContext.request.params.get('role');

        return AccountService.getClientTeam(cifNumber,clientRole);
    }
}