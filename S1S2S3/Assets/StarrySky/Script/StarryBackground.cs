using UnityEngine;

namespace StarrySky
{
	public class StarryBackground : MonoBehaviour
	{
		public enum EStarrySky { Style1, Style2, Style3, Style4, Style5 }
		public EStarrySky m_CurrSky = EStarrySky.Style1;
		EStarrySky m_PrevSky = EStarrySky.Style1;
		Vector2 m_Offset = new Vector2();
		public Vector2 m_Velocity = new Vector2();
		public Material m_StarrySky1;
		public Material m_StarrySky2;
		public Material m_StarrySky3;
		public Material m_StarrySky4;
		public Material m_StarrySky5;
		Renderer m_Rdr;

		void Start()
		{
			m_Rdr = GetComponent<Renderer>();
			Apply();
		}
		void Update()
		{
			if (m_PrevSky != m_CurrSky)
				Apply();
			m_Offset += m_Velocity * 0.001f;
			m_Rdr.material.SetVector("_Offset", m_Offset);
		}
		void Apply()
		{
			if (m_CurrSky == EStarrySky.Style1)
				m_Rdr.material = m_StarrySky1;
			else if (m_CurrSky == EStarrySky.Style2)
				m_Rdr.material = m_StarrySky2;
			else if (m_CurrSky == EStarrySky.Style3)
				m_Rdr.material = m_StarrySky3;
			else if (m_CurrSky == EStarrySky.Style4)
				m_Rdr.material = m_StarrySky4;
			else if (m_CurrSky == EStarrySky.Style5)
				m_Rdr.material = m_StarrySky5;
			m_PrevSky = m_CurrSky;
		}
	}
}