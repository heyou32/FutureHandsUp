using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.InputSystem;
using UnityEngine.XR.Interaction.Toolkit;

public class TeleportManager : MonoBehaviour
{
    [SerializeField] XRRayInteractor leftRayInteractor;
    [SerializeField] InputActionAsset xriInputAction;

    TeleportationProvider teleportationProvider;
    InputAction leftThumbStick;
    bool isActive;
    void Start()
    {
        teleportationProvider = GetComponent<TeleportationProvider>();

        var teleportModeActivate = xriInputAction.FindActionMap("XRI LeftHand").FindAction("Teleport Mode Activate");
        teleportModeActivate.Enable();
        teleportModeActivate.performed += OnTeleportPerformed;

        var teleportModeCancel = xriInputAction.FindActionMap("XRI LeftHand").FindAction("Teleport Mode Cancel");
        teleportModeCancel.Enable();
        teleportModeCancel.performed += OnTeleportCancel;

        leftThumbStick = xriInputAction.FindActionMap("XRI LeftHand").FindAction("Move");
        leftThumbStick.Enable();
    }

    void Update()
    {
        if (!isActive || leftThumbStick.triggered)
        {
            return;
        }

        //이동 처리
        if (leftRayInteractor.TryGetCurrent3DRaycastHit(out RaycastHit hit))
        {
            TeleportRequest request = new TeleportRequest();
            request.destinationPosition = hit.point;

            teleportationProvider.QueueTeleportRequest(request);
        }
       // leftRayInteractor.enabled = false;
        isActive = false;
    }

    void OnTeleportPerformed(InputAction.CallbackContext context)
    {
        leftRayInteractor.enabled = true;
        isActive = true;
    }
    void OnTeleportCancel(InputAction.CallbackContext context)
    {
       // leftRayInteractor.enabled = false;
        isActive = false;
    }

}
