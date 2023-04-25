using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;
using TMPro;

public class OnScreenControls : MonoBehaviour
{
    Particle_Controller particle_Controller;
    [SerializeField] GameObject particleControllerObject;
    [SerializeField] GameObject rainSettingsPanel;
    [SerializeField] GameObject snowSettingsPanel;

    // Start is called before the first frame update
    void Start()
    {
        particle_Controller = particleControllerObject.GetComponent<Particle_Controller>();
    }

    // Update is called once per frame
    void Update()
    {
        if (particle_Controller.weather == Particle_Controller.weatherType.rain)
        {
            rainSettingsPanel.SetActive(true);
            snowSettingsPanel.SetActive(false);
        }

        if (particle_Controller.weather == Particle_Controller.weatherType.snow)
        {
            rainSettingsPanel.SetActive(false);
            snowSettingsPanel.SetActive(true);
        }
    }
}
