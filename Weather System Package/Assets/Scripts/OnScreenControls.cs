using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;
using TMPro;

public class OnScreenControls : MonoBehaviour
{
    Particle_Controller particle_Controller;
    Material_Manager material_Manager;

    [SerializeField] GameObject particleControllerObject;
    [SerializeField] GameObject materialManagerObject;

    [SerializeField] GameObject rainSettingsPanel;
    [SerializeField] GameObject snowSettingsPanel;

    [SerializeField] private Slider wetnessLimit;
    [SerializeField] private Slider occlusionStrengthSlider;

    private List<Material> rainMaterials = new List<Material>();


    // Start is called before the first frame update
    void Start()
    {
        particle_Controller = particleControllerObject.GetComponent<Particle_Controller>();
        material_Manager = materialManagerObject.GetComponent<Material_Manager>();

        wetnessLimit.onValueChanged.AddListener((limit) =>
        {
            particle_Controller.wetnessThreshold = limit;
        });

        rainMaterials.Add(material_Manager.building1rainMat);
        rainMaterials.Add(material_Manager.building2rainMat);
        rainMaterials.Add(material_Manager.building3rainMat);
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
        occlusionStrength();
    }

    void occlusionStrength()
    {
        for (int i = 0; i < rainMaterials.Count; i++)
        {
            float strength = rainMaterials[i].GetFloat("_Occlusion_Strength");

            occlusionStrengthSlider.onValueChanged.AddListener((limit) =>
            {
                strength = limit;
                rainMaterials[i].SetFloat("_Occlusion_Strength", strength);
            });
        }
    }
}
