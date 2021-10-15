using UnityEngine;
using System.Collections;

public class Pyrotechnic_Firework : MonoBehaviour {

public GameObject FireworkFX;

void Start (){

        FireworkFX.SetActive(false);

    }  
  
  
void Update (){
 
    if (Input.GetButtonDown("Fire1")) //check to see if the left mouse was pressed - trigger firework
    {

         StartCoroutine("TriggerFirework");


    }
            
}


IEnumerator TriggerFirework(){

        FireworkFX.SetActive(true);
        yield return new WaitForSeconds(2);
        FireworkFX.SetActive(false);

    }


}