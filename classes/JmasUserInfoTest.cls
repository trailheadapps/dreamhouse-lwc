@isTest
public class JmasUserInfoTest {
    @isTest
    static void testGetCurrentUserId() {
        // Obtener el ID del usuario actual
        Id currentUserId = UserInfo.getUserId();
        
        // Verificar que el ID del usuario actual no sea nulo
        System.assertNotEquals(null, currentUserId);
        
        System.debug('Current User ID: ' + currentUserId);
    }
}